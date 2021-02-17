//
//  PlantConfigurationViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/24/21.
//

import UIKit

class PlantConfigurationViewController: UIViewController {
    enum Section: Hashable, CaseIterable {
        case image
        case plantInfo
        case care
    }

    enum Item: Hashable {
        case plantIcon(PlantIcon)
        case list(image: UIImage?, text: String?, secondaryText: String?)
    }

    var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    var collectionView: UICollectionView! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        configureHiearchy()
        configureDataSource()
    }
}

extension PlantConfigurationViewController {
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: config)
    }

    private func configureHiearchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)

    }
}

extension PlantConfigurationViewController {
    func createDefaultDataSource() -> NSDiffableDataSourceSnapshot<Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        snapshot.appendSections(Section.allCases)

        snapshot.appendItems([
            .list(image: UIImage(systemName: "leaf.fill"), text: "Plant Name", secondaryText: nil),
            .list(image: UIImage(systemName: "leaf.fill"), text: "Plant Type", secondaryText: "Select")
        ], toSection: .plantInfo)

        return snapshot
    }

    func createDataSource(from plant: Plant) -> NSDiffableDataSourceSnapshot<Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        snapshot.appendSections(Section.allCases)

        snapshot.appendItems([
            .plantIcon(plant.icon)
        ], toSection: .image)

        snapshot.appendItems([
            .list(image: UIImage(systemName: "leaf.fill"), text: "Plant Name", secondaryText: plant.name),
            .list(image: UIImage(systemName: "leaf.fill"), text: "Plant Type", secondaryText: plant.type.scientific_name)
        ], toSection: .plantInfo)

        let tasks: [Item] = plant.tasks.map {
            .list(image: $0.iconImage, text: $0.name, secondaryText: $0.interval.description)
        }
        snapshot.appendItems(tasks, toSection: .care)

        return snapshot
    }

    func createPlantIconCellRegistration() -> UICollectionView.CellRegistration<PlantIconCell, Item> {
        return UICollectionView.CellRegistration<PlantIconCell, Item> { (cell, indexPath, item) in
            if case let .plantIcon(icon) = item {
                cell.icon = icon
            }
        }
    }

    func createDefaultListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, Item> { (cell, indexPath, item) in
            var configuration = cell.defaultContentConfiguration()

            if case let .list(image, text, secondaryText) = item {
                configuration.image = image
                configuration.text = text
                configuration.secondaryText = secondaryText
            }

            cell.contentConfiguration = configuration
        }
    }

    private func configureDataSource() {
        let plantIconRegistration = createPlantIconCellRegistration()
        let defaultRegistration = createDefaultListCellRegistration()

        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            switch item {
                case .list:
                    return collectionView.dequeueConfiguredReusableCell(using: defaultRegistration, for: indexPath, item: item)
                case .plantIcon:
                    return collectionView.dequeueConfiguredReusableCell(using: plantIconRegistration, for: indexPath, item: item)
            }
        }

        // initial data
        let snapshot = createDataSource(from: GrowAppModel.preview.getPlants().first!)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
