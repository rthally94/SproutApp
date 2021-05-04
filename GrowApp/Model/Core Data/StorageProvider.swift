//
//  StorageProvider.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/31/21.
//

import Foundation
import CoreData

class StorageProvider {
    let persistentContainer: NSPersistentContainer
    
    init(storeType: StoreType = .persisted) {
        ValueTransformer.setValueTransformer(UIImageTransformer(), forName: NSValueTransformerName("UIImageValueTransformer"))
        persistentContainer = NSPersistentContainer(name: "GreenHouseDataModel")

        if storeType == .inMemory {
            persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        persistentContainer.loadPersistentStores(completionHandler: { description, error in
            if let error = error {
                fatalError("Core Data store failed to load with error: \(error)")
            }
        })
        
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.undoManager = UndoManager()

        let request: NSFetchRequest<GHPlantType> = GHPlantType.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \GHPlantType.plantCount, ascending: true)]
        if let types = try? persistentContainer.viewContext.fetch(request), types.isEmpty {
            loadPlantTypes()
        }
    }

    enum StoreType  {
        case inMemory, persisted
    }
    
    func loadPlantTypes() {
        PlantType.allTypes.forEach { type in
            let newType = GHPlantType(context: persistentContainer.viewContext)
            newType.scientificName = type.scientificName
            newType.commonName = type.commonName
        }
        
        try? persistentContainer.viewContext.save()
    }
}

extension StorageProvider {
    func saveContext() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
