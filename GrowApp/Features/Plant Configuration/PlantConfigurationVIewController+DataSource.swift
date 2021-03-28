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
                cell.onChange = { [weak self] newValue in
                    self?._plant.name = newValue
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

            if case let .list(icon, text, secondaryText) = item.rowType {
                if case let .symbol(symbolName, _) = icon {
                    configuration.image = UIImage(systemName: symbolName)
                } else if case let .image(image) = icon {
                    configuration.image = image
                }
                configuration.text = text
                configuration.secondaryText = secondaryText
            }

            if item.onTap != nil {
                cell.accessories = [.disclosureIndicator()]
            } else if Section.allCases[indexPath.section] == .care {
                cell.accessories = [ .label(text: "Weekly", displayed: .whenNotEditing, options: .init(isHidden: false)), .disclosureIndicator() ]
            }

            cell.contentConfiguration = configuration
        }
    }

    func createSupplementaryHeaderRegistration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            var config = UIListContentConfiguration.largeGroupedHeader()
            let section = Section.allCases[indexPath.section]

            config.text = section.description
            
            supplementaryView.contentConfiguration = config
        }
    }

    func createIconBadgeRegistration() -> UICollectionView.SupplementaryRegistration<PlantIconSupplementaryView> {
        return UICollectionView.SupplementaryRegistration<PlantIconSupplementaryView>(elementKind: PlantIconSupplementaryView.badgeElementKind) { supplementaryView, elementKind, indexPath in
            guard let itemIdentifier: Item = self.dataSource.itemIdentifier(for: indexPath) else { return }

            if case .plantIcon(_) = itemIdentifier.rowType {
                supplementaryView.image = UIImage(systemName: "pencil")
                supplementaryView.tapAction = itemIdentifier.onTap
            }
        }
    }

    func createAddNewReminderFooterRegistration() -> UICollectionView.SupplementaryRegistration<ButtonHeaderFooterView> {
        return UICollectionView.SupplementaryRegistration<ButtonHeaderFooterView>(elementKind: UICollectionView.elementKindSectionFooter) { supplementaryView, elementKind, indexPath in
            let section = Section.allCases[indexPath.section]

            supplementaryView.imageView.image = section.footerImage
            supplementaryView.textLabel.text = section.footerTitle
        }
    }
}

// MARK: - DataSource Configuration
extension PlantConfigurationViewController {
     func makeSnapshot(from plant: Plant) -> NSDiffableDataSourceSnapshot<Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        snapshot.appendSections(Section.allCases)

        snapshot.appendItems([
            Item(
                rowType: .plantIcon(plant.icon),
                onTap: {
                    let vc = PlantIconPickerViewController(plant: plant)
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
                rowType: .listValue(image: nil, text: "Plant Type", secondaryText: plant.type.commonName),
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
                rowType: .list(icon: $0.type.icon, text: $0.type.description, secondaryText: $0.careInfo.description),
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
        let buttonFooterView = createAddNewReminderFooterRegistration()
        let iconBadgeView = createIconBadgeRegistration()
        dataSource.supplementaryViewProvider = { (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            switch elementKind {
                case UICollectionView.elementKindSectionHeader:
                    return collectionView.dequeueConfiguredReusableSupplementary(using: supplementartyHeaderView, for: indexPath)
                case UICollectionView.elementKindSectionFooter:
                    return collectionView.dequeueConfiguredReusableSupplementary(using: buttonFooterView, for: indexPath)
                case PlantIconSupplementaryView.badgeElementKind:
                    return collectionView.dequeueConfiguredReusableSupplementary(using: iconBadgeView, for: indexPath)
                default:
                    return nil
            }
        }

        // initial data
        let snapshot: NSDiffableDataSourceSnapshot<Section, Item>

        snapshot = makeSnapshot(from: _plant)

        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
