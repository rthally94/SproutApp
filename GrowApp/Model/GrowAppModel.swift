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
            let type = PlantType.allTypes.randomElement()!
            let plant = Plant(name: "My Plant \(i)", type: type, icon: .emoji("🐙", backgroundColor: .systemBlue), tasks: tasks)
//            let plant = Plant(name: "My Plant \(i)", type: type, icon: .symbol(name: "tortoise.fill", foregroundColor: nil, backgroundColor: UIColor.systemBlue), tasks: tasks)
            
            let interval = (86_400*i) - 172_800
            let careDate = Date(timeIntervalSinceNow: Double(interval))
            plant.tasks.first?.logCompletedCare(on: careDate)
            
            model.addPlant(plant)
        }
        
        return model
    }
    
    private init() {}
    
    private var plants = Set<Plant>()
    
    // MARK:- Intents
    
    // All Plants
    func getPlants() -> [Plant] {
        return Array(plants)
    }
    
    func addPlant(_ newPlant: Plant) {
        plants.insert(newPlant)
    }
    
    func deletePlant(_ plant: Plant) {
        plants.remove(plant)
    }
    
    // Plant Care
    func getPlantsNeedingCare(on date: Date) -> [TaskType: [Plant]] {
        plants.sorted(by: {$0.name < $1.name}).reduce(into: [TaskType: [Plant]]() ) { dict, plant in
            plant.tasks.forEach { task in
                if task.isDateInInterval(date) {
                    dict[task.type, default: []].append(plant)
                }
            }
        }
    }
}
