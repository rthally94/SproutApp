//
//  PlantTypeViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/21/21.
//

import Combine
import UIKit

class PlantTypePickerViewController: UIViewController {
    typealias Section = PlantTypesProvider.Section
    typealias Item = PlantTypesProvider.Item

    weak var delegate: PlantTypePickerDelegate?
    var selectedType: GHPlantType?
    
    var storageProvider: StorageProvider
    var plantTypesProvider: PlantTypesProvider
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    var cancellables = Set<AnyCancellable>()

    init(plant: GHPlant, storageProvider: StorageProvider) {
        selectedType = plant.type
        self.storageProvider = storageProvider
        self.plantTypesProvider = PlantTypesProvider(storageProvider: storageProvider)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var collectionView: UICollectionView! = nil

    override func loadView() {
        super.loadView()

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
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: makeLayout())
        collectionView.delegate = self

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.pinToBoundsOf(view)
    }

    internal func makeLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.headerMode = .supplementary

        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension PlantTypePickerViewController {
    func makeCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, Item> {[weak self] cell, indexPath, item in
            guard let type = self?.plantTypesProvider.object(withID: item.id) else { return }
            var configuration = cell.defaultContentConfiguration()

            configuration.text = type.commonName
            configuration.secondaryText = type.scientificName
            
            if type == self?.selectedType {
                cell.accessories = [
                    .checkmark()
                ]
            } else {
                cell.accessories = []
            }

            cell.contentConfiguration = configuration
        }
    }

    func createSupplementaryHeaderRegistration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            let section = Section.allCases[indexPath.section]
            var config = UIListContentConfiguration.largeGroupedHeader()
            config.text = section.description
            supplementaryView.contentConfiguration = config
        }
    }

    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        let cellRegistration = makeCellRegistration()

        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        let headerRegistration = createSupplementaryHeaderRegistration()

        dataSource.supplementaryViewProvider = { (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
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
        if let selectedItem = dataSource.itemIdentifier(for: indexPath) {
            selectedType = plantTypesProvider.object(withID: selectedItem.id)
            
            plantTypesProvider.selectItem(selectedItem)
            delegate?.selectedTypeDidChange()
            
            collectionView.deselectItem(at: indexPath, animated: false)
        }
    }
}
