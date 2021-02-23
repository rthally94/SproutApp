//
//  PlantTypeViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/21/21.
//

import UIKit

protocol PlantTypePickerDelegate {
    func plantTypePicker(didSelectType type: PlantType)
}

class PlantTypeViewController: UIViewController {
    var selectedPlantType: PlantType? = nil {
        didSet {
            guard dataSource != nil else { return }
            applySnapshot()
        }
    }

    var plantTypes: [PlantType] = PlantType.allTypes

    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    var delegate: PlantTypePickerDelegate? = nil

    enum Section: Hashable, CaseIterable {
        case recent
        case allPlants
    }

    struct Item: Hashable {
        var id: UUID
        var scientificName: String
        var commonName: String?
        var isSelected: Bool
    }

    override func loadView() {
        super.loadView()

        view.backgroundColor = .systemBackground
        configureHiearchy()
    }
}

extension PlantTypeViewController {
    func configureHiearchy() {
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: makeLayout())

        configureDataSource()
        collectionView.dataSource = dataSource
        collectionView.delegate = self

        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    internal func makeLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension PlantTypeViewController {
    func makeCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            var configuration = cell.defaultContentConfiguration()

            configuration.text = item.commonName
            configuration.secondaryText = item.scientificName

            if item.isSelected {
                let checkmarkImage = UIImage(systemName: "checkmark.circle")
                let accessoryView = UIImageView(image: checkmarkImage)
                let checkmarkAccessory = UICellAccessory.customView(configuration: .init(customView: accessoryView, placement: .trailing(displayed: .always, at: {_ in 0})))
                cell.accessories = [
                    checkmarkAccessory
                ]
            } else {
                cell.accessories = []
            }

            cell.contentConfiguration = configuration
        }
    }

    func configureDataSource() {
        let cellRegistration = makeCellRegistration()

        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        // Apply Initial Snapshot
        applySnapshot()
    }

    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item >()

        snapshot.appendSections(Section.allCases)

        let items = plantTypes.sorted(by: {$0.commonName < $1.commonName}).map { type in
            return Item(id: type.id, scientificName: type.scientificName, commonName: type.commonName, isSelected: type == selectedPlantType)
        }

        snapshot.appendItems(items, toSection: .allPlants)

        dataSource.apply(snapshot)
    }
}

extension PlantTypeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource.itemIdentifier(for: indexPath)
        selectedPlantType = plantTypes.first(where: { $0.id == item?.id })

        guard let selected = selectedPlantType else { return }
        delegate?.plantTypePicker(didSelectType: selected)
    }
}