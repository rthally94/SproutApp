//
//  StaticCollectionView.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/17/21.
//

import UIKit

class StaticCollectionViewController<Section: Hashable>: UIViewController {
    typealias Item = RowItem

    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    override func loadView() {
        super.loadView()

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.pinToBoundsOf(self.view)

        collectionView.backgroundColor = .systemGroupedBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let listCellRegistration = makeListCellRegistration()

        let textFieldCellRegistration = makeTextFieldCellRegistration()

        let iconRegistration = makeIconCellRegistration()
        let headerCellRegistration = makeHeaderCellRegistration()
        let statisticCellRegistration = makeStatisticCellRegistration()
        let todoCellRegistration = makeTodoCellRegistration()
        let compactCardRegistration = makeCompactCardRegistration()

        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item.rowType {
            // UICollectionViewListCell
            case .value1, .value2, .subtitle:
                return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: item)
            // Form Cell
            case .textField:
                return collectionView.dequeueConfiguredReusableCell(using: textFieldCellRegistration, for: indexPath, item: item)
            // Sprout Cell
            case .icon:
                return collectionView.dequeueConfiguredReusableCell(using: iconRegistration, for: indexPath, item: item)
            case .header:
                return collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration, for: indexPath, item: item)
            case .statistic:
                return collectionView.dequeueConfiguredReusableCell(using: statisticCellRegistration, for: indexPath, item: item)
            case .todo:
                return collectionView.dequeueConfiguredReusableCell(using: todoCellRegistration, for: indexPath, item: item)
            case .compactCard:
                return collectionView.dequeueConfiguredReusableCell(using: compactCardRegistration, for: indexPath, item: item)
            }
        }
    }

    /// Defines the layout for the collectionView. Override to define a custom layout
    /// - Returns: The desired layout of the collection view.
    internal func makeLayout() -> UICollectionViewLayout {
        return UICollectionViewFlowLayout()
    }
}

extension StaticCollectionViewController {
    // MARK: - UICollectionViewListCell Configuration
    func makeListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            var config: UIListContentConfiguration
            switch item.rowType {
            case .value1:
                config = UIListContentConfiguration.cell()
            case .value2:
                config = UIListContentConfiguration.valueCell()
            case .subtitle:
                config = UIListContentConfiguration.subtitleCell()
            default:
                fatalError("Invalid rowType: \(item.rowType). List Cell requires rowType of \".value1\", \".value2\", or \".subtitle\"")
            }

            config.image = item.image
            config.imageProperties.tintColor = item.tintColor

            config.text = item.text
            config.secondaryText = item.secondaryText

            cell.contentConfiguration = config
        }
    }

    // MARK: - Form Cell Registraion
    func makeTextFieldCellRegistration() -> UICollectionView.CellRegistration<SproutTextFieldCell, Item> {
        UICollectionView.CellRegistration<SproutTextFieldCell, Item> { cell, indexPath, item in
            cell.updateWith(image: item.image, title: item.text, placeholder: item.secondaryText, value: item.tertiaryText)
        }
    }

    // MARK: - Sprout Cell Registration
    func makeIconCellRegistration() -> UICollectionView.CellRegistration<IconHeaderCell, Item> {
        UICollectionView.CellRegistration<IconHeaderCell, Item> { cell, _, item in
            if let icon = item.icon {
                var config = cell.iconView.defaultConfiguration()
                config.image = icon.image
                config.tintColor = icon.color
                cell.iconView.configuration = config
            }

            cell.backgroundColor = .systemGroupedBackground
        }
    }

    func makeHeaderCellRegistration() -> UICollectionView.CellRegistration<HeaderCell, Item> {
        UICollectionView.CellRegistration<HeaderCell, Item> { cell, indexPath, item in
            cell.titleLabel.text = item.text
            cell.subtitleLabel.text = item.secondaryText
        }
    }

    func makeStatisticCellRegistration() -> UICollectionView.CellRegistration<StatisticCell, Item> {
        UICollectionView.CellRegistration<StatisticCell, Item> { cell, indexPath, item in
            cell.image = item.image
            cell.title = item.text
            cell.value = item.secondaryText
            cell.unit = item.tertiaryText
            cell.tintColor = item.tintColor

            cell.contentView.backgroundColor = .secondarySystemGroupedBackground
            cell.layer.cornerRadius = 10
            cell.clipsToBounds = true
        }
    }

    func makeTodoCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Item> {cell, indexPath, item in
            var config = UIListContentConfiguration.subtitleCell()

            config.image = item.icon?.image ?? item.image
            config.imageProperties.tintColor = item.icon?.color ?? item.tintColor

            config.text = item.text
            config.secondaryText = item.secondaryText

            cell.contentConfiguration = config

            if item.isOn {
                cell.accessories = [ .checkmark() ]
            } else {
                let actionHandler: UIActionHandler = {[weak self] _ in
                    guard let self = self else { return }
                    print("👍")
                }
                cell.accessories = [ .todoAccessory(actionHandler: actionHandler) ]
            }
        }
    }

    func makeCompactCardRegistration() -> UICollectionView.CellRegistration<CompactCardCell, Item> {
        UICollectionView.CellRegistration<CompactCardCell, Item> { cell, indexPath, item in
            cell.image = item.icon?.image ?? item.image
            cell.title = item.text
            cell.value = item.secondaryText
            cell.tintColor = item.icon?.color ?? item.tintColor
        }
    }
}