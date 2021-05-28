//
//  StorageProvider.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/31/21.
//

import CoreData
import UIKit

class StorageProvider {
    static var managedObjectModel: NSManagedObjectModel = {
        let bundle = Bundle(for: StorageProvider.self)
        guard let url = bundle.url(forResource: "GreenHouseDataModel", withExtension: "momd") else {
            fatalError("Failed to load momd file for GreenHouseDataModel")
        }

        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load momd file for GreenHouseDataModel")
        }

        return model
    }()

    let persistentContainer: NSPersistentContainer
    lazy var editingContext: NSManagedObjectContext = {
        let viewContext = persistentContainer.viewContext
        let editingContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        editingContext.parent = viewContext
        editingContext.undoManager = UndoManager()
        return editingContext
    }()
    
    init(storeType: StoreType = .persisted) {
        ValueTransformer.setValueTransformer(UIImageTransformer(), forName: NSValueTransformerName("UIImageValueTransformer"))
        persistentContainer = NSPersistentContainer(name: "GreenHouseDataModel", managedObjectModel:  Self.managedObjectModel)

        if storeType == .inMemory {
            persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        persistentContainer.loadPersistentStores(completionHandler: { description, error in
            if let error = error {
                fatalError("Core Data store failed to load with error: \(error)")
            }
        })
        
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.shouldDeleteInaccessibleFaults = true

        let request: NSFetchRequest<GHPlantType> = GHPlantType.fetchRequest()
        let typeCount = (try? persistentContainer.viewContext.count(for: request)) ?? 0
        if typeCount == 0 {
            loadPlantTypes()
        }
    }

    enum StoreType  {
        case inMemory, persisted
    }
    
    func loadPlantTypes() {
        persistentContainer.performBackgroundTask { context in
            PlantType.allTypes.forEach { type in
                let newType = GHPlantType(context: context)
                newType.scientificName = type.scientificName
                newType.commonName = type.commonName
            }

            try? context.save()
        }
    }

    func loadSampleData() {
        persistentContainer.performBackgroundTask { context in
            do {
                // General Plant Config
                let plant = try GHPlant.createDefaultPlant(inContext: context)
                plant.name = "My Sample Plant"

                // Task Type
                let taskTypeRequest: NSFetchRequest<GHPlantType> = GHPlantType.fetchRequest()
                taskTypeRequest.sortDescriptors = [NSSortDescriptor(keyPath: \GHPlantType.commonName, ascending: true)]
                plant.type = try context.fetch(taskTypeRequest).first

                // Plant Care Info
                let wateringInfo = try CareInfo.createDefaultInfoItem(in: context, ofType: .wateringTaskType)
                let currentWeekday = Calendar.current.component(.weekday, from: Date())
                let wateringSchedule = CareSchedule.weeklySchedule(daysOfTheWeek: [currentWeekday], context: context)
                try wateringInfo.setSchedule(to: wateringSchedule)
                plant.addToCareInfoItems(wateringInfo)

                try context.save()
            } catch {
                print("Unable to load sample data. ")
                context.rollback()
            }
        }
    }
}

extension StorageProvider {
    func saveContext() {
        if editingContext.hasChanges {
            do {
                try editingContext.save()
            } catch {
                editingContext.rollback()
            }
        }

        persistentContainer.saveContextIfNeeded()
    }
}
