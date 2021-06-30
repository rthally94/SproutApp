//
//  StorageProvider.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/31/21.
//

import CoreData
import UIKit

public class StorageProvider {
    public static var managedObjectModel: NSManagedObjectModel = {
        //        let bundle = Bundle(for: StorageProvider.self)
        guard let url = Bundle.module.url(forResource: "SproutCoreDataModel", withExtension: "momd") else {
            fatalError("Failed to get url for SproutCoreDataModel.momd")
        }

        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load momd file for SproutCoreDataModel")
        }

        return model
    }()

    public let persistentContainer: NSPersistentContainer
    
    public init(storeType: StoreType = .persisted) {
        ValueTransformer.setValueTransformer(UIImageTransformer(), forName: NSValueTransformerName("UIImageValueTransformer"))
        persistentContainer = NSPersistentContainer(name: "SproutCoreDataModel", managedObjectModel:  Self.managedObjectModel)

        if storeType == .inMemory {
            persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        persistentContainer.loadPersistentStores(completionHandler: { description, error in
            if let error = error {
                fatalError("Core Data store failed to load with error: \(error)")
            }
        })
        
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy

        persistentContainer.viewContext.shouldDeleteInaccessibleFaults = true
    }

    public enum StoreType  {
        case inMemory, persisted
    }

    public func deleteAllData() {
        guard let store = persistentContainer.persistentStoreCoordinator.persistentStores.first(where: {
            $0.url?.absoluteString.contains("SproutCoreDataModel") == true
        }),
        let url = store.url
        else {
            return
        }

        do {
            persistentContainer.viewContext.reset()
            try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: store.type, options: nil)
            try persistentContainer.persistentStoreCoordinator.addPersistentStore(ofType: store.type, configurationName: nil, at: url, options: nil)
        } catch {
            print("Unable to delete persistent store: \(error)")

        }
    }

    public func loadSampleData() {
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

                        return SproutCareTaskSchedule(startDate: Calendar.current.startOfDay(for: Date()), recurrenceRule: recurrenceRule)!
                    }()

                    let sampleTask = SproutCareTaskMO.insertNewTask(of: .watering, into: context)
                    sampleTask.schedule = schedule

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

public extension StorageProvider {
    func saveContextIfNeeded() {
        persistentContainer.saveContextIfNeeded()
    }
}
