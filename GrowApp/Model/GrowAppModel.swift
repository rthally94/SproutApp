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
        
        return model
    }
    
    private init() {}
    
    private var plants = Set<Plant>()
    
    // MARK:- Intents
    func getPlants() -> [Plant] {
        return Array(plants)
    }
    
    func addPlant(_ newPlant: Plant) {
        plants.insert(newPlant)
    }
    
    func deletePlant(_ plant: Plant) {
        plants.remove(plant)
    }
}
