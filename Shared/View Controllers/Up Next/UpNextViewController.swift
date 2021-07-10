//
//  UpNextViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/29/21.
//

import Combine
import CoreData
import UIKit
import SproutKit

class UpNextViewController: UIViewController {
    static let iconConfiguration = UIImage.SymbolConfiguration(textStyle: .title3)
    static let scheduleFormatter: CareScheduleFormatter = {
        let formatter = CareScheduleFormatter()
        formatter.includesDeterminerPhrase = true
        formatter.valuesStyle = .short
        return formatter
    }()

    // MARK: - Properties
    typealias Section = UpNextProvider.Section
    typealias Item = UpNextProvider.Item
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    weak var delegate: UpNextCoordinator?
    var dataProvider: UpNextProvider

    init(dataProvider: UpNextProvider) {
        self.dataProvider = dataProvider
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var showsCompletedTasks: Bool = false {
        didSet {
            completedTasksDidChange()
        }
    }

    private var lastOpenedDate: Date? {
        didSet {
            completedTasksDidChange()
        }
    }

    private func completedTasksDidChange() {
        configureNavBar(showsAllTasks: showsCompletedTasks)
        dataProvider.completedTaskDateMarker = lastOpenedDate
    }

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var cancellables: Set<AnyCancellable> = []
    private var collectionView: UICollectionView!

    private func makeOptionsMenu(showsAllTasks: Bool) -> UIMenu {
        let completedRemindersAction: UIAction
        if showsAllTasks {
            completedRemindersAction = UIAction(title: "Hide Completed", image: UIImage(systemName: "eye.slash")) { [unowned self] _ in
                self.showsCompletedTasks = false
                self.lastOpenedDate = Date()
            }
        } else {
            completedRemindersAction = UIAction(title: "Show Completed", image: UIImage(systemName: "eye")) { [unowned self] _ in
                self.showsCompletedTasks = true
                self.lastOpenedDate = Calendar.current.startOfDay(for: Date())
            }
        }

        let newMenu = UIMenu(options: .displayInline, children: [completedRemindersAction])
        return newMenu
    }

    // MARK: - View Life Cycle
    override func loadView() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        view = collectionView
        self.collectionView = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = makeDataSource()
        dataProvider.$snapshot
            .sink {[weak self] snapshot in
                if let snapshot = snapshot {
                    self?.dataSource.apply(snapshot)
                }
            }
            .store(in: &cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        lastOpenedDate = Date()
    }

    private func configureNavBar(showsAllTasks: Bool) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: makeOptionsMenu(showsAllTasks: showsAllTasks))
    }
}

// MARK: - Collection View Configuration
private extension UpNextViewController {
    func makeLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .sidebar)

        config.trailingSwipeActionsConfigurationProvider = {[weak self] indexPath in
            guard let self = self else { return UISwipeActionsConfiguration() }
            guard let task = self.dataProvider.object(at: indexPath), task.markStatus == .due else { return nil }
            let markAsDoneAction = UIContextualAction(style: .normal, title: "Mark as done") {action, sourceView, completion in
                self.delegate?.markTaskAsComplete(task)
                completion(true)
            }
            markAsDoneAction.backgroundColor = .systemGreen
            markAsDoneAction.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: Self.iconConfiguration)

            let addEarlyLogAction = UIContextualAction(style: .normal, title: "Add Additional Log") { action, sourceView, completion in
                self.delegate?.markTaskAsComplete(task)
                completion(true)
            }
            addEarlyLogAction.backgroundColor = .systemBlue
            addEarlyLogAction.image = UIImage(systemName: "calendar.badge.plus", withConfiguration: Self.iconConfiguration)

            let actions: [UIContextualAction]
            let isDueToday: Bool
            let isEarly: Bool
            if let dueDate = task.dueDate {
                isDueToday = Calendar.current.isDateInToday(dueDate)
                isEarly = Date() < Calendar.current.startOfDay(for: dueDate)
            } else {
                isDueToday = true
                isEarly = false
            }

            switch (isDueToday, isEarly) {
            case (false, true):
                // Early - Show clock
                actions = [addEarlyLogAction]
            case (true, false):
                // Due or not scheduled - show circle
                actions = [markAsDoneAction]
            case (false, false):
                actions = [markAsDoneAction]
            default:
                actions = []
            }

            return UISwipeActionsConfiguration(actions: actions)
        }

        config.backgroundColor = .systemBackground 

        var separatorConfig = UIListSeparatorConfiguration(listAppearance: .sidebar)
        separatorConfig.bottomSeparatorVisibility = .hidden
        config.separatorConfiguration = separatorConfig

        config.headerMode = .supplementary
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return layout
    }

    // MARK: - Cell Registrations
    func makeTaskCellRegistration() -> UICollectionView.CellRegistration<SproutScheduledTaskCell, Item> {
        UICollectionView.CellRegistration<SproutScheduledTaskCell, Item> {[unowned self] cell, indexPath, item in
            guard let task = self.dataProvider.task(withID: item), let plantID = task.plant?.objectID, let plant = self.dataProvider.plant(withID: plantID) else { return }

            cell.plantName = plant.primaryDisplayName
            cell.plantImage = plant.getImage()
            cell.taskType = task.careInformation?.type?.capitalized
            cell.taskScheduleIcon = UIImage(systemName: task.hasSchedule ? "bell.fill" : "bell.slash")

            if let schedule = task.schedule {
                cell.taskScheduleText = Self.scheduleFormatter.string(from: schedule)
            } else {
                cell.taskScheduleText = "Any Time"
            }

            let isChecked = task.markStatus == .done

            let isDueToday: Bool
            let isEarly: Bool
            if let dueDate = task.dueDate {
                isDueToday = Calendar.current.isDateInToday(dueDate)
                isEarly = Date() < Calendar.current.startOfDay(for: dueDate)
            } else {
                isEarly = false
                isDueToday = true
            }

            switch (isChecked, isDueToday, isEarly) {
            case (true, _, _):
                // Done
                cell.accessories = [ .checkmarkAccessory() ]
            case (false, false, true):
                // Early - Show clock
                cell.accessories = [
                    .buttonAccessory(
                        tintColor: .systemGray3,
                        action: UIAction(image: UIImage(systemName: "clock")) { _ in }
                    )
                ]
            case (false, false, false):
                // Late - Show Exclamation
                cell.accessories = [
                    .buttonAccessory(
                        tintColor: .systemOrange,
                        action: UIAction(image: UIImage(systemName: "exclamationmark.circle")) { _ in
                            self.delegate?.markTaskAsComplete(task)
                        }
                    )
                ]
            case (false, true, false):
                // Due or not scheduled - show circle
                cell.accessories = [
                    .todoAccessory(actionHandler: { _ in
                        self.delegate?.markTaskAsComplete(task)
                    })
                ]
            default:
                cell.accessories = []
            }
        }
    }

    func createHeaderRegistration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) {[unowned self] cell, elementKind, indexPath in
            guard elementKind == UICollectionView.elementKindSectionHeader else { return }
            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]

            var configuration = UIListContentConfiguration.largeGroupedHeader()
            if let date = Utility.ISODateFormatter.date(from: section) {
                configuration.text = Utility.relativeDateFormatter.string(from: date)
            } else {
                configuration.text = "Any Time"
            }

            cell.contentConfiguration = configuration

            let backgroundConfiguration = UIBackgroundConfiguration.listSidebarHeader()
            cell.backgroundConfiguration = backgroundConfiguration
        }
    }

    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        let taskCellRegistration = makeTaskCellRegistration()
        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: taskCellRegistration, for: indexPath, item: item)
        }

        let taskHeader = createHeaderRegistration()
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            switch elementKind {
            case UICollectionView.elementKindSectionHeader:
                return collectionView.dequeueConfiguredReusableSupplementary(using: taskHeader, for: indexPath)
            default:
                return nil
            }
        }

        return dataSource
    }
}

extension UpNextViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}
