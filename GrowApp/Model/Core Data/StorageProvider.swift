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

        let request: NSFetchRequest<SproutPlantMO> = SproutPlantMO.allTemplatesFetchRequest()
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
                SproutPlantMO.createNewPlant(in: context) { newTemplate in
                    newTemplate.scientificName = type.scientificName
                    newTemplate.commonName = type.commonName
                    newTemplate.isTemplate = true
                }
            }

            try? context.save()
        }
    }

    func loadSampleData() {
        persistentContainer.performBackgroundTask { context in
            do {
                // General Plant Config
                let allTemplatesFetchRequest = SproutPlantMO.allTemplatesFetchRequest()
                if let templates = try? context.fetch(allTemplatesFetchRequest), let template = templates.first {
                    try SproutPlantMO.createNewPlant(from: template) { newPlant in
                        newPlant.nickname = "My Sample Plant"
                        SproutCareTaskMO.createNewTask(type: .watering, in: context, completion: { newTask in
                            let schedule = SproutCareTaskSchedule(startDate: Date(), recurrenceRule: .weekly(1, [2,4,6]))
                            newTask.schedule = schedule

                            newPlant.addToCareTasks(newTask)

                            do {
                                try context.save()
                            } catch {
                                print("Unable to save context: \(error)")
                                context.rollback()
                            }
                        })
                    }
                }
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
