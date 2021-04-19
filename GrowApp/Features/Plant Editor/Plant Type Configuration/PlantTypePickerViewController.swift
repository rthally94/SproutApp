//
//  PlantTypeViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/21/21.
//

import Combine
import CoreData
import UIKit

class PlantTypePickerViewController: UIViewController {
    // MARK: - Properties
    typealias Section = PlantTypesProvider.Section
    typealias Item = PlantTypesProvider.Item

    var selectedType: GHPlantType?
    var plantTypesProvider: PlantTypesProvider
    weak var delegate: PlantTypePickerDelegate?
    
    private var collectionView: UICollectionView! = nil
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializers
    init(plant: GHPlant, viewContext: NSManagedObjectContext) {
        self.selectedType = plant.type
        self.plantTypesProvider = PlantTypesProvider(managedObjectContext: viewContext)
        super.init(nibName: nil, bundle: nil)
    }
    
    init(type: GHPlantType?, viewContext: NSManagedObjectContext) {
        self.selectedType = type
        self.plantTypesProvider = PlantTypesProvider(managedObjectContext: viewContext)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Life Cycle
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
            guard let type = self?.plantTypesProvider.object(withID: item) else { return }
            var configuration = cell.defaultContentConfiguration()

            configuration.text = type.commonName
            configuration.secondaryText = type.scientificName
            
            if self?.selectedType == type {
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
        if let newItem = dataSource.itemIdentifier(for: indexPath) {
            let oldItem = selectedType?.objectID
            let newType = plantTypesProvider.object(withID: newItem)
            selectedType = newType
            
            let idsToReload = [oldItem, newItem].compactMap { $0 }
            plantTypesProvider.reloadItems(idsToReload)
            collectionView.deselectItem(at: indexPath, animated: false)
            
            delegate?.plantTypePicker(self, didSelectType: newType)
        }
    }
}
