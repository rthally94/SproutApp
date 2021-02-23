//
//  PlantConfigurationVIewController+DataSource.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/21/21.
//

import UIKit

// MARK: - Cell Registrations
extension PlantConfigurationViewController {
    func createPlantIconCellRegistration() -> UICollectionView.CellRegistration<PlantIconCell, Item> {
        return UICollectionView.CellRegistration<PlantIconCell, Item> { (cell, indexPath, item) in
            if case let .plantIcon(icon) = item.rowType {
                cell.icon = icon
            }
        }
    }

    func createPlantNameCellRegistration() -> UICollectionView.CellRegistration<TextFieldCell, Item> {
        return UICollectionView.CellRegistration<TextFieldCell, Item> { (cell, IndexPath, item) in
            if case let .textField(_, value, placeholder) = item.rowType {
                cell.placeholder = placeholder
                cell.value = value
                cell.onChange = { newValue in
                    print(newValue)
                }
            }
        }
    }

    func createValueCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, Item> { (cell, indexPath, item) in
            var configuration = UIListContentConfiguration.valueCell()

            if case let .listValue(image, text, secondaryText) = item.rowType {
                configuration.image = image
                configuration.text = text
                configuration.secondaryText = secondaryText
            }

            if item.onTap != nil {
                cell.accessories = [.disclosureIndicator()]
            }
            
            cell.contentConfiguration = configuration
        }
    }

    func createDefaultListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, Item> { (cell, indexPath, item) in
            var configuration = cell.defaultContentConfiguration()

            if case let .list(image, text, secondaryText) = item.rowType {
                configuration.image = image
                configuration.text = text
                configuration.secondaryText = secondaryText
            }

            if item.onTap != nil {
                cell.accessories = [.disclosureIndicator()]
            }

            cell.contentConfiguration = configuration
        }
    }

    func createSupplementaryHeaderRegistration() -> UICollectionView.SupplementaryRegistration<CollectionViewHeader> {
        return UICollectionView.SupplementaryRegistration<CollectionViewHeader>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in

            let section = Section.allCases[indexPath.section]

            supplementaryView.textLabel.text = section.description

            if section == .care {
                supplementaryView.accessoryButton.setImage(UIImage(systemName: "plus"), for: .normal)
                supplementaryView.onTap = { print("🍻") }
            }
        }
    }

    func createIconBadgeRegistration() -> UICollectionView.SupplementaryRegistration<PlantIconSupplementaryView> {
        return UICollectionView.SupplementaryRegistration<PlantIconSupplementaryView>(elementKind: PlantIconSupplementaryView.badgeElementKind) { supplementaryView, elementKind, indexPath in
            guard let itemIdentifier: Item = self.dataSource.itemIdentifier(for: indexPath) else { return }

            if case .plantIcon(_) = itemIdentifier.rowType {
                supplementaryView.imageView.image = UIImage(systemName: "pencil.circle.fill")
            }
        }
    }
}

// MARK: - DataSource Configuration
extension PlantConfigurationViewController {
    func createDefaultDataSource() -> NSDiffableDataSourceSnapshot<Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        snapshot.appendSections(Section.allCases)

        snapshot.appendItems([
            Item(
                rowType: .list(image: UIImage(systemName: "leaf.fill"), text: "Plant Name", secondaryText: nil),
                onTap: nil
            ),
            Item(
                rowType: .list(image: UIImage(systemName: "leaf.fill"), text: "Plant Type", secondaryText: "Select"),
                onTap: nil)
        ], toSection: .plantInfo)

        return snapshot
    }

    func createDataSource(from plant: Plant) -> NSDiffableDataSourceSnapshot<Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        snapshot.appendSections(Section.allCases)

        snapshot.appendItems([
            Item(
                rowType: .plantIcon(plant.icon),
                onTap: {
                    let vc = PlantIconPickerViewController(nibName: nil, bundle: nil)
                    vc.plant = plant
                    vc.delegate = self
                    let nav = UINavigationController(rootViewController: vc)
                    self.navigateTo(nav, modal: true)
                })
        ], toSection: .image)

        snapshot.appendItems([
            Item(
                rowType: .textField(image: UIImage(systemName: "leaf.fill"), value: plant.name, placeholder: "Plant Name"),
                onTap: nil
            ),
            Item(
                rowType: .listValue(image: nil, text: "Plant Type", secondaryText: plant.type.scientificName),
                onTap: {
                    let vc = PlantTypeViewController(nibName: nil, bundle: nil)
                    vc.selectedPlantType = plant.type
                    vc.delegate = self
                    self.navigateTo(vc)
                }
            )
        ], toSection: .plantInfo)

        let tasks: [Item] = plant.tasks.map {
            Item(
                rowType: .list(image: $0.iconImage, text: $0.name, secondaryText: $0.interval.description),
                onTap: nil
            )
        }
        snapshot.appendItems(tasks, toSection: .care)

        return snapshot
    }

    internal func configureDataSource() {
        let plantIconRegistration = createPlantIconCellRegistration()
        let plantNameCellRegistration = createPlantNameCellRegistration()
        let valueCellResistration = createValueCellRegistration()
        let defaultRegistration = createDefaultListCellRegistration()

        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            switch item.rowType {
                case .list:
                    return collectionView.dequeueConfiguredReusableCell(using: defaultRegistration, for: indexPath, item: item)
                case .listValue:
                    return collectionView.dequeueConfiguredReusableCell(using: valueCellResistration, for: indexPath, item: item)
                case .plantIcon:
                    return collectionView.dequeueConfiguredReusableCell(using: plantIconRegistration, for: indexPath, item: item)
                case .textField:
                    return collectionView.dequeueConfiguredReusableCell(using: plantNameCellRegistration, for: indexPath, item: item)
            }
        }

        let supplementartyHeaderView = createSupplementaryHeaderRegistration()
        let iconBadgeView = createIconBadgeRegistration()
        dataSource.supplementaryViewProvider = { (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            switch elementKind {
                case UICollectionView.elementKindSectionHeader:
                    return collectionView.dequeueConfiguredReusableSupplementary(using: supplementartyHeaderView, for: indexPath)
                case PlantIconSupplementaryView.badgeElementKind:
                    return collectionView.dequeueConfiguredReusableSupplementary(using: iconBadgeView, for: indexPath)
                default:
                    return nil
            }
        }

        // initial data
        let snapshot: NSDiffableDataSourceSnapshot<Section, Item>

        if let plant = plant {
            snapshot = createDataSource(from: plant)
        } else {
            snapshot = createDefaultDataSource()
        }

        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
