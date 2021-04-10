//
//  GrowAppModel.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/15/21.
//

import Foundation
import UIKit

class GreenHouseAppModel {
    static var shared = GreenHouseAppModel()
    static var preview: GreenHouseAppModel {
        let model = GreenHouseAppModel()
        
        model.plantStore = MemoryPlantStore()
        
        for i in 0...4 {
            let type = PlantType.allTypes[i%PlantType.allTypes.count]
            let plant = model.createPlant()
            plant.name = "My Plant \(i)"
            plant.type = type
            plant.icon = .image(UIImage(named: "SamplePlantImage")!)
            plant.tasks = Task.allTasks[0..<i].map { template in
                var task = template
                task.id = UUID().uuidString
                return task
            }
        }
        
        return model
    }
    
    private init() {}
    
    var plantStore: PlantStore!
    
    // MARK:- Intents
    
    // Plants
    func getPlants() -> [Plant] {
        plantStore.plants
    }
    
    @discardableResult func createPlant() -> Plant {
        let defaultIcon = Icon.symbol(name: "leaf.fill", tintColor: UIColor(named: "ghGreen"))
        let plant = Plant(name: "New Plant", icon: defaultIcon, type: nil, tasks: [])
        plantStore.addPlant(plant)
        return plant
    }
    
    @discardableResult func deletePlant(_ plant: Plant) -> Plant? {
        plantStore.removePlant(plant)
    }
    
    // Plant Care
    func getPlantsNeedingCare(on date: Date) -> [TaskType: [Plant]] {
        plantStore.plants.sorted(by: {$0.name < $1.name}).reduce(into: [TaskType: [Plant]]() ) { dict, plant in
            plant.tasksNeedingCare(on: date).forEach { task in
                dict[task.type, default: []].append(plant)
            }
        }
    }
}
