//
//  GrowAppModel.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/15/21.
//

import Foundation

class GrowAppModel {
    static var shared = GrowAppModel()
    static var preview: GrowAppModel {
        let model = GrowAppModel()
        
        // Configure preconfigured model
        for i in 0...4 {
            let plant = Plant()
            
            let interval = (86_400*i) - 172_800
            let careDate = Date(timeIntervalSinceNow: Double(interval))
            plant.logCare(on: careDate)
            
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
        plants.filter { Calendar.current.isDate($0.nextCareDate, inSameDayAs: date) }
    }
}
