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
    // MARK: - Properties
    typealias Section = UpNextViewModel.Section
    typealias Item = UpNextViewModel.Item
    typealias Snapshot = UpNextViewModel.Snapshot

    var viewModel: UpNextViewModel = UpNextViewModel()

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var cancellables: Set<AnyCancellable> = []

    lazy var collectionView: UICollectionView = { [unowned self] in
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        cv.backgroundColor = .systemBackground
        cv.delegate = self
        return cv
    }()

    private func makeOptionsMenu(showsAllTasks: Bool) -> UIMenu {
        let completedRemindersAction: UIAction
        if showsAllTasks {
            completedRemindersAction = UIAction(title: "Hide Completed", image: UIImage(systemName: "eye.slash")) { [unowned self] _ in
                self.viewModel.hidePreviousCompletedTasks()
            }
        } else {
            completedRemindersAction = UIAction(title: "Show Completed", image: UIImage(systemName: "eye")) { [unowned self] _ in
                self.viewModel.showAllCompletedTasks()
            }
        }

        let newMenu = UIMenu(options: .displayInline, children: [completedRemindersAction])
        return newMenu
    }

    // MARK: - View Life Cycle
    override func loadView() {
        super.loadView()
        setupViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = makeDataSource()

        viewModel.snapshot
            .sink {[weak self] snapshot in
                if let snapshot = snapshot {
                    self?.dataSource.apply(snapshot)
                }
            }
            .store(in: &cancellables)

        viewModel.$doesShowAllCompletedTasks
            .sink { [weak self] showsAllTasks in
                self?.configureNavBar(showsAllTasks: showsAllTasks)
            }
            .store(in: &cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.hidePreviousCompletedTasks()
    }

    private func setupViews() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
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
        config.backgroundColor = .systemBackground
        config.headerMode = .supplementary
        return UICollectionViewCompositionalLayout.list(using: config)
    }

    func makeTaskCellRegistration() -> UICollectionView.CellRegistration<SproutScheduledTaskCell, Item> {
        UICollectionView.CellRegistration<SproutScheduledTaskCell, Item> {[unowned self] cell, indexPath, item in
            guard let task = self.viewModel.task(witID: item), let plantID = task.plant?.objectID, let plant = self.viewModel.plant(withID: plantID) else { return }
            let viewModel = UpNextItem(task: task, plant: plant)
            cell.updateWithText(viewModel.title, subtitle: viewModel.subtitle, image: viewModel.plantIcon, valueImage: viewModel.scheduleIcon, valueText: viewModel.schedule)
            let isChecked = viewModel.isChecked

            if isChecked {
                cell.accessories = [ .checkmark() ]
            } else {
                cell.accessories = [
                    .todoAccessory(actionHandler: {[weak self] _ in
                        self?.viewModel.markTaskAsComplete(id: item)
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

            guard let date = Utility.ISODateFormatter.date(from: section) else { return }
            configuration.text = Utility.relativeDateFormatter.string(from: date)
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
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}
