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

    // MARK: - Properties
    typealias Section = UpNextProvider.Section
    typealias Item = UpNextProvider.Item
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    var coordinator: UpNextCoordinator!
    var persistentContainer: NSPersistentContainer!
    var provider: UpNextProvider!

    private var showsCompletedTasks: Bool = false {
        didSet {
            configureNavBar(showsAllTasks: showsCompletedTasks)
            provider.doesShowCompletedTasks = showsCompletedTasks
        }
    }

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var cancellables: Set<AnyCancellable> = []

    lazy var collectionView: UICollectionView = { [unowned self] in
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        cv.backgroundColor = .systemGroupedBackground
        cv.delegate = self
        return cv
    }()

    private func makeOptionsMenu(showsAllTasks: Bool) -> UIMenu {
        let completedRemindersAction: UIAction
        if showsAllTasks {
            completedRemindersAction = UIAction(title: "Hide Recently Completed", image: UIImage(systemName: "eye.slash")) { [unowned self] _ in
                self.showsCompletedTasks = false
            }
        } else {
            completedRemindersAction = UIAction(title: "Show Recently Completed", image: UIImage(systemName: "eye")) { [unowned self] _ in
                self.showsCompletedTasks = true
            }
        }

        let newMenu = UIMenu(options: .displayInline, children: [completedRemindersAction])
        return newMenu
    }

    // MARK: - View Life Cycle
    override func loadView() {
        setupViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = makeDataSource()
        showsCompletedTasks = false

        provider.$snapshot
            .sink {[weak self] snapshot in
                if let snapshot = snapshot {
                    self?.dataSource.apply(snapshot)
                }
            }
            .store(in: &cancellables)
    }

    private func setupViews() {
        view = collectionView
    }

    private func configureNavBar(showsAllTasks: Bool) {
        title = "Up Next"
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: makeOptionsMenu(showsAllTasks: showsAllTasks))
    }
}

private extension UpNextViewController {
    func makeLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .sidebar)

        config.trailingSwipeActionsConfigurationProvider = {[weak self] indexPath in
            guard let task = self?.provider.object(at: indexPath), let dueDate = task.dueDate, task.markStatus == .due else { return nil }
            let isDueToday = Calendar.current.isDateInToday(dueDate)
            let isEarly = Date() < Calendar.current.startOfDay(for: dueDate)

            let markAsDoneAction = UIContextualAction(style: .normal, title: "Mark as done") {action, sourceView, completion in
                self?.coordinator.markAsComplete(task: task)
                completion(true)
            }
            markAsDoneAction.backgroundColor = .systemGreen
            markAsDoneAction.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: Self.iconConfiguration)

            let addEarlyLog = UIContextualAction(style: .normal, title: "Add Additional Log") {action, sourceView, completion in
                self?.coordinator.markAsComplete(task: task)
                completion(true)
            }
            addEarlyLog.backgroundColor = .systemBlue
            addEarlyLog.image = UIImage(systemName: "calendar.badge.plus", withConfiguration: Self.iconConfiguration)


            let actions: [UIContextualAction]
            if isDueToday {
                actions = [markAsDoneAction]
            } else if isEarly {
                actions = [addEarlyLog]
            } else {
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

    func makeTaskCellRegistration() -> UICollectionView.CellRegistration<SproutScheduledTaskCell, Item> {
        UICollectionView.CellRegistration<SproutScheduledTaskCell, Item> {[unowned self] cell, indexPath, item in
            guard let task = self.provider.task(withID: item), let plantID = task.plant?.objectID, let plant = self.provider.plant(withID: plantID) else { return }

            cell.plantName = plant.primaryDisplayName
            cell.plantImage = plant.getImage()
            cell.taskType = task.careInformation?.type?.capitalized
            cell.taskScheduleIcon = UIImage(systemName: task.hasSchedule ? "bell.fill" : "bell.slash")
            cell.taskScheduleText = task.schedule?.description ?? "Not scheduled"

            let isChecked = task.markStatus == .done
            let isDueToday: Bool
            if let dueDate = task.dueDate {
                isDueToday = Calendar.current.isDateInToday(dueDate)
            } else {
                isDueToday = false
            }

            if isChecked {
                cell.accessories = [ .checkmarkAccessory() ]
            } else if isDueToday {
                cell.accessories = [
                    .todoAccessory(actionHandler: {[weak self] _ in
                        self?.coordinator.markAsComplete(task: task)
                    })
                ]
            } else {
                cell.accessories = [
                    .buttonAccessory(
                        tintColor: .systemGray3,
                        action: UIAction(image: UIImage(systemName: "clock")) { _ in }
                    )
                ]
            }
        }
    }

    func createHeaderRegistration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) {[unowned self] cell, elementKind, indexPath in
            guard elementKind == UICollectionView.elementKindSectionHeader else { return }
            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            guard let date = Utility.ISODateFormatter.date(from: section) else { return }

            var configuration = UIListContentConfiguration.largeGroupedHeader()
            configuration.text = Utility.relativeDateFormatter.string(from: date)
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
