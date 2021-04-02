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
    
    init() {
        ValueTransformer.setValueTransformer(UIImageTransformer(), forName: NSValueTransformerName("UIImageValueTransformer"))
        persistentContainer = NSPersistentContainer(name: "GreenHouseDataModel")
        
        persistentContainer.loadPersistentStores(completionHandler: { description, error in
            if let error = error {
                fatalError("Core Data store failed to load with error: \(error)")
            }
        })
    }
}
