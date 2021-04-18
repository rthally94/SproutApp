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

        let iconRegistration = makeIconCellRegistration()
        let headerCellRegistration = makeHeaderCellRegistration()
        let statisticCellRegistration = makeStatisticCellRegistration()
        let todoCellRegistration = makeTodoCellRegistration()
        let listCellRegistration = makeListCellRegistration()
        let compactCardRegistration = makeCompactCardRegistration()

        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item.rowType {
            case .icon:
                return collectionView.dequeueConfiguredReusableCell(using: iconRegistration, for: indexPath, item: item)
            case .header:
                return collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration, for: indexPath, item: item)
            case .statistic:
                return collectionView.dequeueConfiguredReusableCell(using: statisticCellRegistration, for: indexPath, item: item)
            case .todo:
                return collectionView.dequeueConfiguredReusableCell(using: todoCellRegistration, for: indexPath, item: item)
            case .value1, .value2, .subtitle:
                return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: item)
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

    struct RowItem: Hashable {
        typealias Icon = GHIcon

        enum RowType: Hashable {
            case value1, value2, subtitle
            case compactCard
            case icon, header
            case statistic
            case todo
        }

        var id: UUID
        var rowType: RowType

        var text: String?
        var secondaryText: String?
        var tertiaryText: String?
        var image: UIImage?
        var icon: Icon?
        var isOn: Bool
        var tintColor: UIColor?


        /// Memberwise Initialzier. Not all properties are used in every row type.
        /// - Parameters:
        ///   - id: Unique Identifier of the item
        ///   - rowType: Visual representation of the row
        ///   - text: Primary Text
        ///   - secondaryText: Secondary Text
        ///   - tertiaryText: Tertiary Text
        ///   - image: Image to display
        ///   - icon: Icon to display
        ///   - isOn: Flag to represent the state of a switch with an on/off state
        init(id: UUID = UUID(), rowType: RowType, text: String? = nil, secondaryText: String? = nil, tertiaryText: String? = nil, image: UIImage? = nil, icon: Icon? = nil, isOn: Bool = false, tintColor: UIColor? = .systemBlue) {
            self.id = id
            self.rowType = rowType
            self.text = text
            self.secondaryText = secondaryText
            self.tertiaryText = tertiaryText
            self.image = image
            self.icon = icon
            self.isOn = isOn
            self.tintColor = tintColor
        }

        /// Initializer for a UICollectionViewListCell
        /// - Parameters:
        ///   - id: Unique identifier for the item
        ///   - text: The primary text
        ///   - secondaryText: The secondary text
        ///   - image: The image to display
//        init(id: UUID = UUID(), rowType: RowType = .value1, text: String? = nil, secondaryText: String? = nil, image: UIImage? = nil) {
//            self.init(id: id, rowType: rowType, text: text, secondaryText: secondaryText, image: image)
//        }

        /// Initialzier for the Plant Icon
        /// - Parameters:
        ///   - id: Unique identifier for the item
        ///   - icon: The icon
        init(id: UUID = UUID(), icon: Icon?) {
            self.init(id: id, rowType: .icon, icon: icon)
        }

        /// Initializer for the plant header
        /// - Parameters:
        ///   - id: Unique identifier for the item
        ///   - title: The title
        ///   - subtitle: The subtitle
        init(id: UUID = UUID(), title: String?, subtitle: String?) {
            self.init(id: id, rowType: .header, text: title, secondaryText: subtitle)
        }

        /// Initializer for the statistic cell
        /// - Parameters:
        ///   - id: Unique identifier for the item
        ///   - title: The title
        ///   - value: The value
        ///   - unit: The unit
        ///   - icon: The icon
        ///   - tintColor: Primary tint color of the item
        init(id: UUID = UUID(), title: String?, value: String?, unit: String? = nil, image: UIImage? = nil, icon: Icon? = nil, tintColor: UIColor? = nil) {
            self.init(id: id, rowType: .statistic, text: title, secondaryText: value, tertiaryText: unit, image: image, icon: icon, tintColor: tintColor)
        }

        /// Initializer for a todo cell
        /// - Parameters:
        ///   - id: Unique identifier for the item
        ///   - title: The title
        ///   - subtitle: The subtitle
        ///   - image: The image
        ///   - icon: The icon
        ///   - taskState: Flag to represent the state of a switch with an on/off state
        ///   - tintColor: Primary tint color of the item
        init(id: UUID = UUID(), title: String?, subtitle: String?, image: UIImage? = nil, icon: Icon? = nil, taskState: Bool, tintColor: UIColor? = nil) {
            self.init(id: id, rowType: .todo, text: title, secondaryText: subtitle, image: image, icon: icon, isOn: taskState, tintColor: tintColor)
        }
    }
}

extension StaticCollectionViewController {
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

    func makeCompactCardRegistration() -> UICollectionView.CellRegistration<CompactCardCell, Item> {
        UICollectionView.CellRegistration<CompactCardCell, Item> { cell, indexPath, item in
            cell.image = item.icon?.image ?? item.image
            cell.title = item.text
            cell.value = item.secondaryText
            cell.tintColor = item.icon?.color ?? item.tintColor
        }
    }
}
