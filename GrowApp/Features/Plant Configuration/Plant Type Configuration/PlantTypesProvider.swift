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
    
    private var allTypes: [NSManagedObjectID: GHPlantType] = [:]
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

    typealias Item = NSManagedObjectID
    
    init(storageProvider: StorageProvider) {
        self.storage = storageProvider
        
        super.init()
        
        // Fetch plant types
        let allTypesRequest: NSFetchRequest<GHPlantType> = GHPlantType.fetchRequest()
        allTypesRequest.sortDescriptors = [NSSortDescriptor(keyPath: \GHPlantType.commonName, ascending: true)]
        let types = (try? storageProvider.persistentContainer.viewContext.fetch(allTypesRequest)) ?? []
        allTypes = types.reduce(into: [NSManagedObjectID: GHPlantType]()) { dict, type in
            dict[type.objectID] = type
        }
        
        // Make Snapshot
        var newSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        newSnapshot.appendSections([.allPlants])
        
        let items = allTypes.sorted(by: { lhs, rhs in
            if let lName = lhs.value.commonName, let rName = rhs.value.commonName {
                return lName < rName
            } else if lhs.value.commonName != nil {
                return true
            } else {
                return false
            }
        }).map { $0.key }
        
        newSnapshot.appendItems(items)
        snapshot = newSnapshot
    }
    
    func object(withID id: NSManagedObjectID) -> GHPlantType {
        storage.persistentContainer.viewContext.object(with: id) as! GHPlantType
    }
    
    func reloadItems(_ items: [Item]) {
        var newSnapshot = snapshot
        newSnapshot?.reloadItems(items)
        snapshot = newSnapshot
    }
}
