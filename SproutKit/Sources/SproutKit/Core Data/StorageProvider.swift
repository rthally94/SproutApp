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
            let latePlant = SproutPlantMO.insertNewPlant(using: .sampleData[0], into: context)
            latePlant.nickname = "Sample Plant: Late Care"
            self.makeLateTask(plant: latePlant, context: context)

            let duePlant = SproutPlantMO.insertNewPlant(using: .sampleData[1], into: context)
            duePlant.nickname = "Sample Plant: Due Care"
            self.makeDueTask(plant: duePlant, context: context)

            let earlyPlant = SproutPlantMO.insertNewPlant(using: .sampleData[2], into: context)
            earlyPlant.nickname = "Sample Plant: Early Care"
            self.makeEarlyTask(plant: earlyPlant, context: context)

            let unscheduledPlant = SproutPlantMO.insertNewPlant(using: .sampleData[3], into: context)
            unscheduledPlant.nickname = "Sample Plant: Any Time Care"
            self.makeUnscheduledTask(plant: unscheduledPlant, context: context)

            do {
                try context.saveIfNeeded()
            } catch {
                print("Unable to save changes to background context: \(error)")
            }
        }
    }

    @discardableResult private func makeLateTask(plant: SproutPlantMO, context: NSManagedObjectContext) -> SproutCareTaskMO {
        let lateTask = SproutCareTaskMO.insertNewTask(of: .watering, into: context)
        let lateStartDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let lateTaskSchedule = SproutCareTaskSchedule(startDate: lateStartDate, recurrenceRule: .daily(1))
        lateTask.schedule = lateTaskSchedule

        lateTask.careInformation?.plant = plant
        plant.addToCareTasks(lateTask)
        return lateTask
    }

    @discardableResult private func makeDueTask(plant: SproutPlantMO, context: NSManagedObjectContext) -> SproutCareTaskMO {
        let dueTask = SproutCareTaskMO.insertNewTask(of: .watering, into: context)
        let dueStartDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let dueTaskSchedule = SproutCareTaskSchedule(startDate: dueStartDate, recurrenceRule: .daily(1))
        dueTask.schedule = dueTaskSchedule

        dueTask.careInformation?.plant = plant
        plant.addToCareTasks(dueTask)
        return dueTask
    }

    @discardableResult private func makeEarlyTask(plant: SproutPlantMO, context: NSManagedObjectContext) -> SproutCareTaskMO {
        let earlyTask = SproutCareTaskMO.insertNewTask(of: .watering, into: context)
        let earlyStartDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let earlyTaskSchedule = SproutCareTaskSchedule(startDate: earlyStartDate, recurrenceRule: .daily(2))
        earlyTask.schedule = earlyTaskSchedule

        earlyTask.careInformation?.plant = plant
        plant.addToCareTasks(earlyTask)
        return earlyTask
    }

    @discardableResult private func makeUnscheduledTask(plant: SproutPlantMO, context: NSManagedObjectContext) -> SproutCareTaskMO {
        let unscheduledTask = SproutCareTaskMO.insertNewTask(of: .watering, into: context)
        unscheduledTask.careInformation?.plant = plant
        plant.addToCareTasks(unscheduledTask)
        return unscheduledTask
    }
}

public extension StorageProvider {
    func saveContextIfNeeded() {
        persistentContainer.saveContextIfNeeded()
    }
}
