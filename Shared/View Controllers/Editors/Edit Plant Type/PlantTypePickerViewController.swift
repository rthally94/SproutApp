//
//  PlantTypeViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/21/21.
//

import Combine
import CoreData
import UIKit
import SproutKit

class PlantTypePickerViewController: UIViewController {
    // MARK: - Properties

    typealias Section = PlantTypesProvider.Section
    typealias Item = PlantTypesProvider.Item

    var selectedType: SproutPlantTemplate?

    lazy var plantTypesProvider = PlantTypesProvider(managedObjectContext: persistentContainer.viewContext)
    var persistentContainer: NSPersistentContainer = AppDelegate.persistentContainer {
        didSet {
            plantTypesProvider = PlantTypesProvider(managedObjectContext: persistentContainer.viewContext)
        }
    }

    weak var delegate: PlantTypePickerDelegate?

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var cancellables = Set<AnyCancellable>()

    // MARK: - View Life Cycle

    override func loadView() {
        configureHiearchy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = makeDataSource()

        plantTypesProvider.$snapshot
            .sink(receiveValue: { snapshot in
                if let snapshot = snapshot {
                    self.dataSource.apply(snapshot)
                }
            })
            .store(in: &cancellables)

        title = "Plant Types"
    }
}

extension PlantTypePickerViewController {
    func configureHiearchy() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view = collectionView

        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
    }

    func makeLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.headerMode = .supplementary

        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension PlantTypePickerViewController {
    func makeCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, Item> { [weak self] cell, _, item in
            var configuration = cell.defaultContentConfiguration()

            configuration.text = item.commonName
            configuration.secondaryText = item.scientificName

            if self?.selectedType == item {
                cell.accessories = [
                    .checkmark(),
                ]
            } else {
                cell.accessories = []
            }

            cell.contentConfiguration = configuration
        }
    }

    func createSupplementaryHeaderRegistration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, _, indexPath in
            let section = Section.allCases[indexPath.section]
            var config = UIListContentConfiguration.largeGroupedHeader()
            config.text = section.description
            supplementaryView.contentConfiguration = config
        }
    }

    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        let cellRegistration = makeCellRegistration()

        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        let headerRegistration = createSupplementaryHeaderRegistration()

        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath -> UICollectionReusableView? in
            switch elementKind {
            case UICollectionView.elementKindSectionHeader:
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            default:
                return nil
            }
        }

        return dataSource
    }
}

extension PlantTypePickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let newItem = dataSource.itemIdentifier(for: indexPath) {
            let oldItem = selectedType
            selectedType = newItem

            let idsToReload = [oldItem, newItem].compactMap { $0 }

            // FIXME: May not refresh cells
            plantTypesProvider.reloadItems(idsToReload)
            collectionView.deselectItem(at: indexPath, animated: false)

            delegate?.plantTypePicker(self, didSelectType: newItem)
        }
    }
}
