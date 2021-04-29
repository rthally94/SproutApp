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

    let viewContext: NSManagedObjectContext
    let tasksProvider: TasksProvider

    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    var cancellables: Set<AnyCancellable> = []

    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        cv.backgroundColor = .clear
        cv.delegate = self
        return cv
    }()

    // MARK: - Initializers
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.tasksProvider = TasksProvider(managedObjectContext: viewContext)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Life Cycle
    override func loadView() {
        super.loadView()
        setupViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = makeDataSource()
        tasksProvider.$snapshot
            .sink {[weak self] snapshot in
                if let snapshot = snapshot {
                    self?.dataSource.apply(snapshot)
                }
            }
            .store(in: &cancellables)

        title = "Up Next"
    }

    private func setupViews() {
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}

private extension UpNextViewController {
    func makeLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .sidebarPlain)
        config.headerMode = .supplementary
        return UICollectionViewCompositionalLayout.list(using: config)
    }

    func makeTaskCellRegistration() -> UICollectionView.CellRegistration<TaskCalendarListCell, Item> {
        UICollectionView.CellRegistration<TaskCalendarListCell, Item> {[weak self] cell, indexPath, item in
            guard let task = self?.tasksProvider.object(at: indexPath) else { return }
            cell.updateWithTask(task)
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
