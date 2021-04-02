//
//  PlantTypesProvider.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/2/21.
//

import CoreData
import UIKit

class PlantTypesProvider: NSObject {    
    let storage: StorageProvider
    
    private var allTypes = [GHPlantType]()
    private var selectedItem: Item?
    @Published var snapshot: NSDiffableDataSourceSnapshot<Section, Item>?
    
    enum Section: Int, Hashable, CaseIterable, CustomStringConvertible {
        case recent
        case allPlants

        var description: String {
            switch self {
                case .recent: return "Recent Plants"
                case .allPlants: return "All Plants"
            }
        }
    }

    struct Item: Hashable {
        var id: NSManagedObjectID
        var isSelected: Bool
    }
    
    init(storageProvider: StorageProvider) {
        self.storage = storageProvider
        
        super.init()
        
        let allTypesRequest: NSFetchRequest<GHPlantType> = GHPlantType.fetchRequest()
        allTypesRequest.sortDescriptors = [NSSortDescriptor(keyPath: \GHPlantType.commonName, ascending: true)]
        allTypes = (try? storageProvider.persistentContainer.viewContext.fetch(allTypesRequest)) ?? []
        
        var newSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        newSnapshot.appendSections([.allPlants])
        let allItems = allTypes.map { type in
            Item(id: type.objectID, isSelected: false)
        }
        newSnapshot.appendItems(allItems)
        snapshot = newSnapshot
    }
    
    func object(withID id: NSManagedObjectID) -> GHPlantType {
        storage.persistentContainer.viewContext.object(with: id) as! GHPlantType
    }
    
    func selectItem(_ item: Item) {
        let idsToReload = [item, selectedItem].compactMap { $0 }
        
        snapshot?.reloadItems(idsToReload)
        selectedItem = item
    }
}
