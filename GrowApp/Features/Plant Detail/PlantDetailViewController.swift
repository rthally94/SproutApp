//
//  PlantDetailViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/2/21.
//

import CoreData
import UIKit

enum PlantDetailSection: Int, CaseIterable {
    case plantHero
    case taskSummary
    case upNext
    case careInfo

    func headerTitle() -> String? {
        switch self {
        case .upNext:
            return "Up Next"
        case .careInfo:
            return "Care Info"
        default:
            return nil
        }
    }

    func headerSubtitle() -> String? {
        switch self {
        case .careInfo:
            return ""
        default:
            return nil
        }
    }

    func headerIcon() -> UIImage? {
        switch self {
        default:
            return nil
        }
    }
}

class PlantDetailViewController: StaticCollectionViewController<PlantDetailSection> {
    // MARK: - Properties
    let dateComponentsFormatter = Utility.dateComponentsFormatter
    let careDateFormatter = Utility.relativeDateFormatter

    var persistentContainer: NSPersistentContainer = AppDelegate.persistentContainer
    var plant: GHPlant?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let headerRegistration = makeInsetGroupedSectionHeaderRegistration()
        dataSource.supplementaryViewProvider = { (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            switch elementKind {
            case UICollectionView.elementKindSectionHeader:
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            default:
                return nil
            }
        }

        collectionView.delegate = self
        updateUI()
        
        title = "Plant Details"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPlant))
    }
    
    //MARK: - Actions
    @objc private func editPlant() {
        let vc = AddEditPlantCollectionViewController(plant: plant, storageProvider: AppDelegate.storageProvider)
        vc.delegate = self
        present(vc.wrappedInNavigationController(), animated: true)
    }

    internal override func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let sectionKind = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]
            let section: NSCollectionLayoutSection

            switch sectionKind {
            case .plantHero:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.85))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
            case .taskSummary:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.48), heightDimension: .estimated(64))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(64))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .flexible(6)

                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 16, bottom: 0, trailing: 16)
            case .careInfo:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(64))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(64))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .flexible(6)

                section = NSCollectionLayoutSection(group: group)
                if sectionKind.headerTitle() != nil {
                    let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
                    let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                    section.boundarySupplementaryItems = [headerItem]
                }
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            case .upNext:
                var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                if sectionKind.headerTitle() != nil {
                    config.headerMode = .supplementary
                }
                section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            }

            if sectionKind.headerTitle() != nil {
                let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
                let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [headerItem]
            }
            return section
        }

        return layout
    }
}

extension PlantDetailViewController: AddEditPlantViewControllerDelegate {
    func plantEditor(_ editor: AddEditPlantViewController, didUpdatePlant plant: GHPlant) {
        
        if plant.isDeleted {
            navigationController?.popViewController(animated: false)
        }
        
        persistentContainer.saveContextIfNeeded()
        updateUI()
    }
}

private extension PlantDetailViewController {
    func nextTaskDateString() -> String {
        let nextTaskDate = plant?.tasks.map { $0.nextCareDate ?? Date() }.min() ?? Date()
        return careDateFormatter.string(from: nextTaskDate)
    }
}

private extension PlantDetailViewController {
    func makeSnapshot() -> NSDiffableDataSourceSnapshot<PlantDetailSection, Item> {
        guard let id = plant?.objectID, let plant = persistentContainer.viewContext.object(with: id) as? GHPlant else { fatalError("Could not get plant from context") }
        var snapshot = NSDiffableDataSourceSnapshot<PlantDetailSection, Item>()
        snapshot.appendSections([PlantDetailSection.plantHero, PlantDetailSection.careInfo])
        
        // Plant Info Header
        snapshot.appendItems([
            .hero(image: plant.icon?.image, title: plant.name, subtitle: plant.type?.commonName)
        ], toSection: .plantHero)
        
        // All Tasks
        let currentScheduleFormatter = Utility.currentScheduleFormatter
        let items: [Item] = plant.tasks.map { task in
            return Item.compactCardCell(title: task.careCategory?.name, value: currentScheduleFormatter.string(for: task.currentSchedule), image: task.careCategory?.icon?.image, tapAction: { [unowned self] in
                print(task.careCategory?.name ?? "Unknown")
            })
        }
        
        snapshot.appendItems(items, toSection: .careInfo)
        return snapshot
    }

    func makeInsetGroupedSectionHeaderRegistration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { cell, elementKind, indexPath in
            guard elementKind == UICollectionView.elementKindSectionHeader else { return }
            var config = UIListContentConfiguration.largeGroupedHeader()

            guard let section = PlantDetailSection(rawValue: indexPath.section) else { return }
            config.text = section.headerTitle()?.capitalized

            cell.contentConfiguration = config
            cell.contentView.backgroundColor = .systemGroupedBackground
        }
    }
}

extension PlantDetailViewController {
    func configureHiearchy() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.pinToBoundsOf(view)
    }
    
    func updateUI() {
        let snapshot = makeSnapshot()
        dataSource.apply(snapshot)
    }
}

extension PlantDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let item = dataSource.itemIdentifier(for: indexPath)
        return item?.isTappable ?? false
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource.itemIdentifier(for: indexPath)
        item?.tapAction?()
    }
}
