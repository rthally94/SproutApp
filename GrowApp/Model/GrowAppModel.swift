//
//  GrowAppModel.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/15/21.
//

import Foundation
import UIKit

class GrowAppModel {
    static var shared = GrowAppModel()
    static var preview: GrowAppModel {
        let model = GrowAppModel()
        
        // Configure preconfigured model
        for i in 0...4 {
            let tasks = Array(Task.allTasks[0..<i])
            let type = PlantType.allTypes[i%PlantType.allTypes.count]
            let plant = model.plantStore.createPlant()
            plant.name = "My Plant \(i)"
            plant.type = type
            plant.icon = .image(UIImage(named: "SamplePlantImage")!)
            plant.tasks = tasks
            
            if let task = tasks.first {
                plant.tasks[0].startingDate = Date().addingTimeInterval(-86400 * 7)
                let logOnInterval = task.previousCareDate(before: Date())!
                let logOffInterval = logOnInterval.addingTimeInterval(-86400)
                let careDate = i%2 == 0 ? logOnInterval : logOffInterval
                plant.tasks[0].logCompletedCare(on: careDate)
            }
        }
        
        return model
    }
    
    private init() {}
    
    var plantStore = PlantStore()
    
    // MARK:- Intents
    
    // All Plants
    func getPlants() -> [Plant] {
        plantStore.allPlants()
    }
    
    func getPlant(with id: UUID) -> Plant? {
        plantStore.plant(withID: id.uuidString)
    }
    
    func addPlant() {
        plantStore.createPlant()
    }
    
    func deletePlant(_ plant: Plant) {
        plantStore.deletePlant(withID: plant.id.uuidString)
    }
    
    // Plant Care
    func getPlantsNeedingCare(on date: Date) -> [TaskType: [Plant]] {
        plantStore.allPlants().sorted(by: {$0.name < $1.name}).reduce(into: [TaskType: [Plant]]() ) { dict, plant in
            plant.tasksNeedingCare(on: date).forEach { task in
                dict[task.type, default: []].append(plant)
            }
        }
    }
}
