//
//  PlantDetailViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/2/21.
//

import CoreData
import UIKit
import SproutKit

class PlantDetailViewController: UIViewController {
    private static let maxNumberOfHistoryItems = 5

    private typealias Section = ViewModel.Section
    private typealias Item = ViewModel.Item

    // MARK: - Properties
    let dateComponentsFormatter = Utility.dateComponentsFormatter
    let careDateFormatter = Utility.relativeDateFormatter

    weak var delegate: PlantDetailCoordinator?

    var storageProvider: StorageProvider
    var viewContext: NSManagedObjectContext {
        storageProvider.persistentContainer.viewContext
    }

    var plant: SproutPlantMO

    private var upNextTasks: [SproutCareTaskMO] {
        let request = SproutCareTaskMO.needsCareOnDateFetchRequest(date: Date(), plant: plant)
        let tasks = (try? viewContext.fetch(request)) ?? []
        return tasks
    }

    init?(plant: NSManagedObjectID, storageProvider: StorageProvider) {
        guard let existingPlant = try? storageProvider.persistentContainer.viewContext.existingObject(with: plant) as? SproutPlantMO else { return nil }
        self.plant = existingPlant
        self.storageProvider = storageProvider

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) cannot be used. PlantDetailViewController requires dependency injection.")
    }

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    func refreshUI(animated: Bool = true) {
        applySnapshot(animatingDifferences: animated)
    }
    
    // MARK: - View Life Cycle
    override func loadView() {
        configureCollectionView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = makeDataSource()

        collectionView.delegate = self
        
        title = "Plant Details"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPlant))

        refreshUI(animated: false)
    }
    
    //MARK: - Actions
    @objc private func editPlant() {
        delegate?.edit(plant: plant)
    }
}

// MARK: Static Collection View Model
private extension PlantDetailViewController {
    enum ViewModel {
        enum Section: Hashable, CaseIterable {
            case upNext
            case careInfo

            var headerText: String? {
                switch self {
                case .upNext:
                    return "Up Next"
                case .careInfo:
                    return "All Tasks"
                }
            }
        }

        enum Item: Hashable {
            case careTask(CareTaskItemConfiguration)
            case careDetail(CareDetailItemConfiguration)
            case careHistory(CareHistoryConfiguration)
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
            case .upNext, .careInfo:
                var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                config.headerMode = sectionKind.headerText != nil ? .supplementary : .none
                section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            }
            return section
        }

        let detailHeroSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.8))
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
            case .careDetail:
                return collectionView.dequeueConfiguredReusableCell(using: taskCellRegistraion, for: indexPath, item: item)
            case .careHistory:
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
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.upNext, .careInfo])
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)

        var upNextSectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        let upNextItems: [Item] = upNextTasks.map { task in
            let configuration = CareTaskItemConfiguration(task: task) { [unowned self] in
                self.delegate?.markTaskAsComplete(task)
                self.refreshUI()
            }
            return Item.careTask(configuration)
        }

        if !upNextItems.isEmpty {
            upNextSectionSnapshot.append(upNextItems)
            dataSource.apply(upNextSectionSnapshot, to: .upNext, animatingDifferences: animatingDifferences)
        }

        // All Tasks
        var allTasksSectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        for taskType in plant.allCareInformation {
            let careDetailConfig = CareDetailItemConfiguration(careInformation: taskType, handler: {
                print("Should show history items")
            })
            let careDetailItem = Item.careDetail(careDetailConfig)

            let historyItems: [Item] = taskType.completedTasks.prefix(Self.maxNumberOfHistoryItems).map { history in
                let config = CareHistoryConfiguration(task: history)
                return Item.careHistory(config)
            }

            allTasksSectionSnapshot.append([careDetailItem])
            allTasksSectionSnapshot.append(historyItems, to: careDetailItem)
        }

        dataSource.apply(allTasksSectionSnapshot, to: .careInfo, animatingDifferences: animatingDifferences)
    }
}

// MARK: Cell Registrations
private extension PlantDetailViewController {
    private func makeUICollectionListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            switch item {
            case let .careTask(configuration):
                var config = UIListContentConfiguration.valueCell()
                config.image = configuration.icon
                config.text = configuration.taskName
                config.secondaryText = configuration.taskSchedule
                config.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .caption1)
                config.prefersSideBySideTextAndSecondaryText = false
                cell.contentConfiguration = config

                if configuration.isDue {
                    cell.accessories = [
                        .todoAccessory(actionHandler: { _ in
                            configuration.handler?()
                        })
                    ]
                } else {
                    cell.accessories = [
                        .checkmarkAccessory()
                    ]
                }

            case let .careDetail(configuration):
                var config = UIListContentConfiguration.valueCell()
                config.image = configuration.image
                config.text = configuration.title
                config.secondaryText = configuration.subtitle
                config.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .caption1)
                config.prefersSideBySideTextAndSecondaryText = false
                cell.contentConfiguration = config
                cell.accessories = [.outlineDisclosure()]

            case let .careHistory(configuration):
                var cellConfiguration = UIListContentConfiguration.valueCell()
                cellConfiguration.image = configuration.icon
                cellConfiguration.text = configuration.status?.rawValue.capitalized

                if let date = configuration.statusDate {
                cellConfiguration.secondaryText = Utility.dateFormatter.string(from: date)
                }

                cell.contentConfiguration = cellConfiguration
                cell.accessories = []
            }
        }
    }

    private func makeDetailHeroRegistration() -> UICollectionView.SupplementaryRegistration<DetailHeroReusableView> {
        UICollectionView.SupplementaryRegistration<DetailHeroReusableView>(elementKind: UICollectionView.elementKindLayoutHeader) { [unowned self] view, elementKind, indexPath in
            view.titleText = plant.primaryDisplayName
            view.subtitleText = plant.secondaryDisplayName

            var iconConfig = view.defaultIconConfiguration()
            iconConfig.image = plant.getImage() ?? UIImage.PlaceholderPlantImage
            view.iconConfiguration = iconConfig

            view.backgroundImage = plant.getImage() ?? UIImage.PlaceholderPlantImage
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

extension UICollectionView {
    static let elementKindLayoutHeader = "element-kind-layout-header"
}
