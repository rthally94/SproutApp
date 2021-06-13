//
//  PlantDetailViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/2/21.
//

import CoreData
import UIKit

class PlantDetailViewController: UIViewController {
    private typealias Section = ViewModel.Section
    private typealias Item = ViewModel.Item

    // MARK: - Properties
    let dateComponentsFormatter = Utility.dateComponentsFormatter
    let careDateFormatter = Utility.relativeDateFormatter

    var persistentContainer: NSPersistentContainer = AppDelegate.persistentContainer
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    var plant: SproutPlantMO?

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    // MARK: - View Life Cycle
    override func loadView() {
        configureCollectionView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = makeDataSource()

        collectionView.delegate = self
        
        title = "Plant Details"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPlant))

        dataSource.apply(makeSnapshot())
    }
    
    //MARK: - Actions
    @objc private func editPlant() {
        let vc = AddEditPlantViewController(plant: plant, storageProvider: AppDelegate.storageProvider)
        vc.delegate = self
        present(vc.wrappedInNavigationController(), animated: true)
    }
}

// MARK: Static Collection View Model
private extension PlantDetailViewController {
    enum ViewModel {
        enum Section: Hashable, CaseIterable {
            case tasks

            var headerText: String? {
                switch self {
                case .tasks:
                    return "All Tasks"
                default:
                    return nil
                }
            }
        }

        enum Item: Hashable {
            case careTask(id: NSManagedObjectID)
//            case careTask(image: UIImage? = nil, taskName: String, taskSchedule: String?)
        }
    }
}

// MARK: Collection View Setup
private extension PlantDetailViewController {
    func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemGroupedBackground
        view = collectionView
    }

    func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let sectionKind = Section.allCases[sectionIndex]
            let section: NSCollectionLayoutSection

            switch sectionKind {
            case .tasks:
                var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                config.headerMode = sectionKind.headerText != nil ? .supplementary : .none
                section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            }

            if sectionKind.headerText != nil {
                let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
                let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [headerItem]
            }
            return section
        }

        let detailHeroSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.35))
        let detailHeroSupplementary = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: detailHeroSize, elementKind: UICollectionView.elementKindLayoutHeader, alignment: .top)

        let configuration = layout.configuration
        configuration.boundarySupplementaryItems = [
            detailHeroSupplementary
        ]

        layout.configuration = configuration

        return layout
    }
}

// MARK: - Data Source Setup
private extension PlantDetailViewController {
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        let taskCellRegistraion = makeUICollectionListCellRegistration()

        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .careTask:
                return collectionView.dequeueConfiguredReusableCell(using: taskCellRegistraion, for: indexPath, item: item)
            }
        }

        let headerRegistration = makeInsetGroupedSectionHeaderRegistration()
        let layoutHeaderRegistration = makeDetailHeroRegistration()

        dataSource.supplementaryViewProvider = { (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            switch elementKind {
            case UICollectionView.elementKindSectionHeader:
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            case UICollectionView.elementKindLayoutHeader:
                return collectionView.dequeueConfiguredReusableSupplementary(using: layoutHeaderRegistration, for: indexPath)
            default:
                return nil
            }
        }

        return dataSource
    }
}

// MARK: Snapshots
private extension PlantDetailViewController {
    private func makeSnapshot() -> NSDiffableDataSourceSnapshot<Section, Item> {
        guard let plant = plant else { fatalError("Unable to show detail view for plant - \(plant)") }

        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)

        // All Tasks
        let items: [Item] = plant.allTasks.filter({ task in
            task.historyLog == nil
        }).map { task in
            return Item.careTask(id: task.objectID)
        }

        snapshot.appendItems(items, toSection: .tasks)
        return snapshot
    }
}

// MARK: Cell Registrations
private extension PlantDetailViewController {
    private func makeUICollectionListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Item> { [weak self] cell, indexPath, item in
            switch item {
            case let .careTask(id):
                guard let task = self?.viewContext.object(with: id) as? SproutCareTaskMO else { break }
                let viewModel = SproutCareTaskCellViewModel(careTask: task)
                var config = UIListContentConfiguration.valueCell()
                config.image = viewModel.image
                config.text = viewModel.title
                config.secondaryText = viewModel.subtitle
                config.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .caption1)
                config.prefersSideBySideTextAndSecondaryText = false
                cell.contentConfiguration = config
            default:
                return
            }
        }
    }

    private func makeDetailHeroRegistration() -> UICollectionView.SupplementaryRegistration<DetailHeroReusableView> {
        UICollectionView.SupplementaryRegistration<DetailHeroReusableView>(elementKind: UICollectionView.elementKindLayoutHeader) { [unowned self] view, elementKind, indexPath in
            view.titleText = plant?.primaryDisplayName
            view.subtitleText = plant?.secondaryDisplayName

            var iconConfig = view.defaultIconConfiguration()
            iconConfig.image = plant?.icon
            view.iconConfiguration = iconConfig

            view.backgroundImage = plant?.icon
        }
    }

    private func makeInsetGroupedSectionHeaderRegistration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { [unowned self] cell, elementKind, indexPath in
            guard elementKind == UICollectionView.elementKindSectionHeader else { return }
            var config = UIListContentConfiguration.largeGroupedHeader()

            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            config.text = section.headerText?.capitalized

            cell.contentConfiguration = config
            cell.contentView.backgroundColor = .systemGroupedBackground
        }
    }
}

// MARK: - Collection View Delegate
extension PlantDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let item = dataSource.itemIdentifier(for: indexPath)
        switch item {
        default:
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource.itemIdentifier(for: indexPath)
        switch item {
        default:
            break
        }
    }
}

// MARK: - Plant Editor Delegate
extension PlantDetailViewController: AddEditPlantViewControllerDelegate {
    func plantEditor(_ editor: AddEditPlantViewController, didUpdatePlant plant: SproutPlantMO) {

        if plant.isDeleted {
            navigationController?.popViewController(animated: false)
        }

        persistentContainer.saveContextIfNeeded()
    }
}

extension UICollectionView {
    static let elementKindLayoutHeader = "element-kind-layout-header"
}