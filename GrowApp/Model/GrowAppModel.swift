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
    
    private var plants = [Plant]()
    
    // MARK:- Intents
    
    func getPlants() -> [Plant] {
        return plants
    }
    
    func addPlant(_ newPlant: Plant) {
        if !plants.contains(newPlant) {
            plants.append(newPlant)
        }
    }
    
    func deletePlant(atIndex index: Int) {
        if index >= plants.startIndex && index < plants.endIndex {
            plants.remove(at: index)
        }
    }
}
