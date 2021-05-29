//
//  PlantTypesProvider.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/2/21.
//

import CoreData
import UIKit

class PlantTypesProvider: NSObject {    
    let moc: NSManagedObjectContext
    
    private var allTypes: [NSManagedObjectID: SproutPlantType] = [:]
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
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.moc = managedObjectContext
        
        super.init()
        
        // Fetch plant types
        let allTypesRequest: NSFetchRequest<SproutPlantType> = SproutPlantType.fetchRequest()
        allTypesRequest.sortDescriptors = [NSSortDescriptor(keyPath: \SproutPlantType.commonName, ascending: true)]
        let types = (try? moc.fetch(allTypesRequest)) ?? []
        allTypes = types.reduce(into: [NSManagedObjectID: SproutPlantType]()) { dict, type in
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
    
    func object(withID id: NSManagedObjectID) -> SproutPlantType {
        moc.object(with: id) as! SproutPlantType
    }
    
    func reloadItems(_ items: [Item]) {
        var newSnapshot = snapshot
        newSnapshot?.reloadItems(items)
        snapshot = newSnapshot
    }
}