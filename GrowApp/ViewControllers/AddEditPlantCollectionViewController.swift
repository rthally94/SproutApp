//
//  AddEditPlantTableViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/24/21.
//

import UIKit

class AddEditPlantCollectionViewController: StaticCollectionViewController<ViewModel.Section> {
    typealias Section = ViewModel.Section
    typealias Item = ViewModel.Item

    enum ViewModel {
        enum Section: CaseIterable {
            case image
            case plantInfo
            case plantCare
            case unconfiguredCare
            case actions

            var headerTitle: String? {
                switch self {
                case .plantCare:
                    return "Care Details"
                default:
                    return nil
                }
            }
        }

        enum Item: Hashable {
            case icon(UIImage?, UIColor = .systemBlue)
            case textField(placeholder: String?, initialValue: String?)
            case navigationLink(title: String, detailText: String? = nil, onTap: HashableClosure<Void>)
            case careDetail(icon: UIImage?, title: String, detail: String? = nil, tintColor: UIColor)
            case button(icon: UIImage?, title: String, tintColor: UIColor? = .systemBlue, context: ButtonCell.DisplayMode = .normal, onTap: HashableClosure<Void>)
        }
    }

    var dataSouce: UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>!

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.setCollectionViewLayout(makeLayout(), animated: false)
    }
}

fileprivate extension AddEditPlantCollectionViewController {
    func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout() { sectionIndex, layoutEnvironment in
            let sectionKind = ViewModel.Section.allCases[sectionIndex]

            switch sectionKind {
            case .icon:
                let imageItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let imageItem = NSCollectionLayoutItem(layoutSize: imageItemSize)
                imageItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

                let buttonItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(40))
                let buttonItem = NSCollectionLayoutItem(layoutSize: buttonItemSize)

                let imageGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1.0))
                let imageGroup = NSCollectionLayoutGroup.vertical(layoutSize: imageGroupSize, subitems: [imageItem])

                let mainGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
                let mainGroup = NSCollectionLayoutGroup.vertical(layoutSize: mainGroupSize, subitems: [imageGroup, buttonItem])
                mainGroup.interItemSpacing = .fixed(10)

                let edgeInset = layoutEnvironment.container.effectiveContentSize.width / 3.5
                let section = NSCollectionLayoutSection(group: mainGroup)
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: edgeInset, bottom: 0, trailing: edgeInset )
                return section
//            case .plantCare, .unconfiguredCare:
//                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(64))
//                let item = NSCollectionLayoutItem(layoutSize: itemSize)
//
//                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(64))
//                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//                group.interItemSpacing = .flexible(6)
//
//                let section = NSCollectionLayoutSection(group: group)
//                if sectionKind.headerTitle != nil {
//                    let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
//                    let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
//                    section.boundarySupplementaryItems = [headerItem]
//                }
//                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
//                return section
            default:
                var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                config.headerMode = sectionKind.headerTitle != nil ? .supplementary : .none

                return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            }
        }

        return layout
    }

    func createDataSouce() -> UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item> {
        let iconCellRegistration = iconCellRegistration()
        let buttonCellRegistration = buttonCellRegistration()

        let dataSource = UICollectionViewDiffableDataSource<ViewModel.Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .icon:
                return collectionView.dequeueConfiguredReusableCell(using: iconCellRegistration, for: indexPath, item: item)
            case .button:
                return collectionView.dequeueConfiguredReusableCell(using: buttonCellRegistration, for: indexPath, item: item)

            }
        }
    }

    func applyInitialSnapshot() {

    }
}

private extension AddEditPlantCollectionViewController {
    func iconCellRegistration() -> UICollectionView.CellRegistration<IconCell, Item> {
        UICollectionView.CellRegistration<IconCell, Item> { cell, indexPath, item in
            guard case let .icon(image, tintColor) = item else { return }

            var config = cell.defaultConfigurtion()
            config.image = image
            config.tintColor = tintColor
            cell.contentConfiguration = config
            cell.backgroundColor = .systemGroupedBackground
        }
    }

    func buttonCellRegistration() -> UICollectionView.CellRegistration<SproutButtonCell, Item>  {
        UICollectionView.CellRegistration<SproutButtonCell, Item> { cell, indexPath, item in
            guard case let .button(icon, title, tintColor, context, _) = item else { return }
            cell.image = icon
            cell.title = title
            cell.tintColor = tintColor
            cell.displayMode = context
        }
    }
}
