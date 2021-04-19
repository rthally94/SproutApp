//
//  PlantConfigurationVIewController+DataSource.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/21/21.
//

import UIKit

// MARK: - DataSource Configuration
extension PlantEditorControllerController {
    func makeSnapshot(from plant: GHPlant) -> NSDiffableDataSourceSnapshot<PlantEditorSection, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<PlantEditorSection, Item>()
        snapshot.appendSections(PlantEditorSection.allCases)
        // Header Image
        snapshot.appendItems([
            RowItem.icon(icon: plant.icon)
        ], toSection: .image)
        
        // General Plant Info
        snapshot.appendItems([
            Item.textFieldCell(placeholder: "My New Plant", initialValue: plant.name, onChange: { _ in }),
            Item.listCell(rowType: .value2, text: "Type", secondaryText: plant.type?.commonName ?? "Choose Type")
        ], toSection: .plantInfo)
        
        // Plant Tasks
        let tasks: [Item] = plant.tasks.compactMap { task in
            Item.compactCardCell(title: task.taskType?.name, value: task.interval?.intervalText() ?? "Tap to configure", image: task.taskType?.icon?.image)
        }
        snapshot.appendItems(tasks, toSection: .care)
        
        //        let deleteItem = Item.butto(rowType: .button(image: UIImage(systemName: "trash.fill"), text: "Delete Plant", tintColor: UIColor.systemRed))
        //        snapshot.appendItems([deleteItem], toSection: .actions)
        return snapshot
    }

    internal func configureDataSource() {
        let supplementartyHeaderView = createSupplementaryHeaderRegistration()
        let buttonFooterView = createAddNewReminderFooterRegistration()
        dataSource.supplementaryViewProvider = { (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            switch elementKind {
            case UICollectionView.elementKindSectionHeader:
                return collectionView.dequeueConfiguredReusableSupplementary(using: supplementartyHeaderView, for: indexPath)
            case UICollectionView.elementKindSectionFooter:
                return collectionView.dequeueConfiguredReusableSupplementary(using: buttonFooterView, for: indexPath)
            default:
                return nil
            }
        }

        // initial data
        let snapshot: NSDiffableDataSourceSnapshot<PlantEditorSection, Item>

        snapshot = makeSnapshot(from: editingPlant)

        dataSource.apply(snapshot, animatingDifferences: false)
    }

    func createSupplementaryHeaderRegistration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            guard let section = PlantEditorSection(rawValue: indexPath.section) else { return }
            var config = UIListContentConfiguration.largeGroupedHeader()
            config.text = section.description
            supplementaryView.contentConfiguration = config
            supplementaryView.contentView.backgroundColor = .systemGroupedBackground
        }
    }

    func createAddNewReminderFooterRegistration() -> UICollectionView.SupplementaryRegistration<ButtonHeaderFooterView> {
        return UICollectionView.SupplementaryRegistration<ButtonHeaderFooterView>(elementKind: UICollectionView.elementKindSectionFooter) { supplementaryView, elementKind, indexPath in
            guard let section = PlantEditorSection(rawValue: indexPath.section) else { return }

            supplementaryView.imageView.image = section.footerImage
            supplementaryView.textLabel.text = section.footerTitle
        }
    }
}