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
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

        collectionView.backgroundColor = .systemGroupedBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let listCellRegistration = makeListCellRegistration()

        let textFieldCellRegistration = makeTextFieldCellRegistration()
        let buttonCellRegistration = makeButtonCellRegistration()
        let pickerRowCellRegistration = makePickerCellRegistration()

        let iconRegistration = makeIconCellRegistration()
        let heroRegistration = makeHeroCellRegistration()
        let headerCellRegistration = makeHeaderCellRegistration()
        let largeHeaderCellRegistration = makeLargeHeaderCellRegistration()
        let statisticCellRegistration = makeStatisticCellRegistration()
        let todoCellRegistration = makeTodoCellRegistration()
        let compactCardRegistration = makeCompactCardRegistration()
        let customViewCellRegistration = makeCustomViewCellRegistration()


        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item.rowType {
            // UICollectionViewListCell
            case .value1, .value2, .subtitle:
                return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: item)
            // Form Cell
            case .textField:
                return collectionView.dequeueConfiguredReusableCell(using: textFieldCellRegistration, for: indexPath, item: item)
            case .button, .circleButton:
                return collectionView.dequeueConfiguredReusableCell(using: buttonCellRegistration, for: indexPath, item: item)
            case .pickerRow:
                return collectionView.dequeueConfiguredReusableCell(using: pickerRowCellRegistration, for: indexPath, item: item)
            // Sprout Cell
            case .icon:
                return collectionView.dequeueConfiguredReusableCell(using: iconRegistration, for: indexPath, item: item)
            case .hero:
                return collectionView.dequeueConfiguredReusableCell(using: heroRegistration, for: indexPath, item: item)
            case .header:
                return collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration, for: indexPath, item: item)
            case .largeHeader:
                return collectionView.dequeueConfiguredReusableCell(using: largeHeaderCellRegistration, for: indexPath, item: item)
            case .statistic:
                return collectionView.dequeueConfiguredReusableCell(using: statisticCellRegistration, for: indexPath, item: item)
            case .todo:
                return collectionView.dequeueConfiguredReusableCell(using: todoCellRegistration, for: indexPath, item: item)
            case .compactCard:
                return collectionView.dequeueConfiguredReusableCell(using: compactCardRegistration, for: indexPath, item: item)
            case .customView:
                return collectionView.dequeueConfiguredReusableCell(using: customViewCellRegistration, for: indexPath, item: item)
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
    private func makeListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
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

            cell.accessories = item.accessories ?? []
        }
    }

    // MARK: - Form Cell Registraion
    private func makeTextFieldCellRegistration() -> UICollectionView.CellRegistration<SproutTextFieldCell, Item> {
        UICollectionView.CellRegistration<SproutTextFieldCell, Item> { cell, indexPath, item in
            cell.updateWith(image: item.image, title: item.text, placeholder: item.secondaryText, value: item.tertiaryText, onChange: item.valueChangedAction)
        }
    }

    private func makeButtonCellRegistration() -> UICollectionView.CellRegistration<SproutButtonCell, Item> {
        UICollectionView.CellRegistration<SproutButtonCell, Item> { cell, indexPath, item in
            cell.title = item.text
            cell.image = item.image
            cell.tintColor = item.tintColor
            cell.isSelected = item.isOn

            if case .plain = item.displayContext {
                cell.displayMode = .plain
            } else if case .normal = item.displayContext {
                cell.displayMode = .normal
            } else if case .primary = item.displayContext {
                cell.displayMode = .primary
            } else if case .destructive = item.displayContext {
                cell.displayMode = .destructive
            }

            if item.rowType == .circleButton {
                cell.layer.cornerRadius = cell.bounds.height/2
            } else {
                cell.layer.cornerRadius = 10
            }
                cell.clipsToBounds = true
        }
    }

    // MARK: - Sprout Cell Registration
    func makeIconCellRegistration() -> UICollectionView.CellRegistration<IconCell, Item> {
        UICollectionView.CellRegistration<IconCell, Item> { cell, _, item in
            var config = cell.defaultConfigurtion()
            config.image = item.image
            config.tintColor = item.tintColor
            cell.contentConfiguration = config
            cell.backgroundColor = .systemGroupedBackground
        }
    }

    func makeHeroCellRegistration() -> UICollectionView.CellRegistration<HeroCell, Item> {
        UICollectionView.CellRegistration<HeroCell, Item> { cell, indexPath, item in
            cell.image = item.image
            cell.headerTitle = item.text
            cell.headerSubtitle = item.secondaryText
        }
    }

    func makeHeaderCellRegistration() -> UICollectionView.CellRegistration<HeaderCell, Item> {
        UICollectionView.CellRegistration<HeaderCell, Item> { cell, indexPath, item in
            cell.titleLabel.text = item.text
            cell.subtitleLabel.text = item.secondaryText
        }
    }

    func makeLargeHeaderCellRegistration() -> UICollectionView.CellRegistration<LargeHeaderCell, Item> {
        UICollectionView.CellRegistration<LargeHeaderCell, Item> { cell, indexPathm, item in
            cell.image = item.image
            cell.title = item.text
            cell.value = item.secondaryText
            cell.tintColor = item.tintColor

            cell.layer.cornerRadius = 10
            cell.clipsToBounds = true
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

            config.image = item.image
            config.imageProperties.tintColor = item.tintColor

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

    func makePickerCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            var config = UIListContentConfiguration.subtitleCell()

            config.image = item.image
            config.imageProperties.tintColor = item.tintColor

            config.text = item.text
            config.secondaryText = item.secondaryText

            cell.contentConfiguration = config
            cell.accessories = item.isOn ? [ .checkmark() ] : []
        }
    }

    func makeCompactCardRegistration() -> UICollectionView.CellRegistration<CompactCardCell, Item> {
        UICollectionView.CellRegistration<CompactCardCell, Item> { cell, indexPath, item in
            cell.image = item.image
            cell.title = item.text
            cell.value = item.secondaryText
            cell.tintColor = item.tintColor
        }
    }

    func makeCustomViewCellRegistration() -> UICollectionView.CellRegistration<CustomViewCell, Item> {
        UICollectionView.CellRegistration<CustomViewCell, Item> { cell, indexPath, item in
            cell.customView = item.customView
            cell.backgroundColor = .clear
        }
    }
}
