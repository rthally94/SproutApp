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
            let tasks = [
                Task(name: "Never Task", iconImage: UIImage(systemName: "swift"), interval: .none, logs: []),
                Task(name: "Daily Task", iconImage: UIImage(systemName: "swift"), interval: .daily(1), logs: []),
                Task(name: "Weekly Task", iconImage: UIImage(systemName: "swift"), interval: .weekly([1, 3, 5]), logs: []),
                Task(name: "Monthly Task", iconImage: UIImage(systemName: "swift"), interval: .monthly([10, 20]), logs: [])
            ]

            let type = PlantType.allTypes.randomElement()!
            let plant = Plant(name: "My Plant \(i)", type: type, icon: .symbol(name: "drop.fill", foregroundColor: UIColor.systemBlue, backgroundColor: UIColor.secondarySystemGroupedBackground), tasks: tasks)
            
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
    func getPlantsNeedingCare(on date: Date) -> [Plant] {
        plants.filter { plant in
            for task in plant.tasks {
                if Calendar.current.isDate(task.nextCareDate, inSameDayAs: date) == true {
                    return true
                }
            }
            
            return false
        }
    }
}
