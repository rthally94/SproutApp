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
            RowItem.icon(image: plant.icon?.image, tapAction: { [unowned self] in
                showIconEditor()
            }),
            
            RowItem.button(context: .normal, title: "Edit", onTap: {[unowned self] in
                showIconEditor()
            })
        ], toSection: .image)
        
        // General Plant Info
        snapshot.appendItems([
            Item.textField(placeholder: "My New Plant", initialValue: plant.name, onChange: { newValue in
                guard let value = newValue as? String else { return }
                plant.name = value
            }),
            Item.listCell(rowType: .value2, text: "Type", secondaryText: plant.type?.commonName ?? "Choose Type", tapAction: { [unowned self] in
                navigateTo(plantTypePicker)
            })
        ], toSection: .plantInfo)
        
        // Plant Tasks
        let tasks: [Item] = plant.tasks.compactMap { task in
            Item.compactCardCell(title: task.taskType?.name, value: task.interval?.intervalText() ?? "Tap to configure", image: task.taskType?.icon?.image, tapAction: {[unowned self] in
                print(task.taskType?.name ?? "Unknown")
                showTaskEditor(for: task)
            })
        }
        snapshot.appendItems(tasks, toSection: .care)
        
        let deleteItem = Item.button(context: .destructive, title: "Delete Plant", image: UIImage(systemName: "trash.fill"), onTap: { })
        snapshot.appendItems([deleteItem], toSection: .actions)
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

        snapshot = makeSnapshot(from: plant)

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
