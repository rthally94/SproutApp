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
        guard let url = bundle.url(forResource: "SproutDataModel", withExtension: "momd") else {
            fatalError("Failed to load momd file for SproutDataModel")
        }

        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load momd file for SproutDataModel")
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
        persistentContainer = NSPersistentContainer(name: "SproutDataModel", managedObjectModel:  Self.managedObjectModel)

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
    }

    enum StoreType  {
        case inMemory, persisted
    }

    func loadSampleData() {
        persistentContainer.performBackgroundTask { context in
            do {
                // General Plant Config
                SproutPlantTemplate.sampleData.enumerated().forEach { index, template in
                    let samplePlant = SproutPlantMO.insertNewPlant(using: template, into: context)
                    samplePlant.nickname = "My Sample Plant \(index+1)"

                    // Add a task
                    let schedule: SproutCareTaskSchedule = {
                        let recurrenceRule: SproutCareTaskRecurrenceRule
                        switch index {
                        case 0:
                            recurrenceRule = SproutCareTaskRecurrenceRule.daily(1)
                        case 1:
                            recurrenceRule = SproutCareTaskRecurrenceRule.weekly(1, [2,4,6])
                        case 2:
                            recurrenceRule = SproutCareTaskRecurrenceRule.monthly(1, [1, 15])
                        default:
                            recurrenceRule = SproutCareTaskRecurrenceRule.daily(7)
                        }

                        return SproutCareTaskSchedule(startDate: Date(), recurrenceRule: recurrenceRule)!
                    }()

                    let sampleTask = SproutCareTaskMO.insertNewTask(of: .watering, into: context)
                    sampleTask.schedule = schedule
                    sampleTask.markAs(.due)

                    sampleTask.careInformation?.plant = samplePlant
                    samplePlant.addToCareTasks(sampleTask)
                }
            }

            do {
                try context.saveIfNeeded()
            } catch {
                print("Unable to save changes to background context: \(error)")
            }
        }
    }
}

extension StorageProvider {
    func saveContext() {
        try? editingContext.saveIfNeeded()
        persistentContainer.saveContextIfNeeded()
    }
}
