//
//  UpNextViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/29/21.
//

import Combine
import CoreData
import UIKit

class UpNextViewController: UIViewController {
    // MARK: - Properties
    typealias Section = TasksProvider.Section
    typealias Item = TasksProvider.Item
    private let dateFormatter = Utility.relativeDateFormatter

    var persistentContainer: NSPersistentContainer = AppDelegate.persistentContainer
    private var tasksProvider: TasksProvider?

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var cancellables: Set<AnyCancellable> = []

    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        cv.backgroundColor = .clear
        cv.delegate = self
        return cv
    }()

    // MARK: - View Life Cycle
    override func loadView() {
        super.loadView()
        setupViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tasksProvider = TasksProvider(managedObjectContext: persistentContainer.viewContext)

        dataSource = makeDataSource()

        title = "Up Next"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tasksProvider?.$snapshot
            .sink {[weak self] snapshot in
                if let snapshot = snapshot {
                    self?.dataSource.apply(snapshot)
                }
            }
            .store(in: &cancellables)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        cancellables.forEach {
            $0.cancel()
        }

        cancellables.removeAll()
    }

    private func setupViews() {
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}

private extension UpNextViewController {
    func makeLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.headerMode = .supplementary
        return UICollectionViewCompositionalLayout.list(using: config)
    }

    func makeTaskCellRegistration() -> UICollectionView.CellRegistration<TaskCalendarListCell, Item> {
        UICollectionView.CellRegistration<TaskCalendarListCell, Item> {[weak self] cell, indexPath, item in
            guard let task = self?.tasksProvider?.object(at: indexPath) else { return }
            cell.updateWithTask(task)

            if let lastLogDate = task.lastLogDate,
               let nextCareDate = task.nextCareDate,
               let difference = Calendar.current.dateComponents([.day], from: lastLogDate, to: nextCareDate).day,
               difference <= 0
            {
                cell.accessories = [ .checkmark() ]
            } else {
                cell.accessories = [
                    .todoAccessory(actionHandler: {_ in
                        task.markAsComplete()
                        self?.persistentContainer.saveContextIfNeeded()
                    })
                ]
            }

        }
    }

    func createHeaderRegistration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) {[unowned self] cell, elementKind, indexPath in
            guard elementKind == UICollectionView.elementKindSectionHeader else { return }
            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            var configuration = UIListContentConfiguration.largeGroupedHeader()
            configuration.text = section
            //            configuration.secondaryText = itemCount == 1 ? "\(itemCount) task" : "\(itemCount) tasks"
            cell.contentConfiguration = configuration
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

}
