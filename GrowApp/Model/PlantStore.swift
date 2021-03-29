//
//  PlantStore.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/29/21.
//

import Foundation

class PlantStore {
    private var plants: [Plant] = []
}

extension PlantStore {
    // Lookup
    func allPlants() -> [Plant] {
        return plants
    }
    
    func plant(withID id: String) -> Plant? {
        return plants.first(where: {$0.id.uuidString == id})
    }
    
    // Create
    @discardableResult func createPlant() -> Plant {
        let newPlant = Plant(name: "New Plant", type: .init(scientificName: "New", commonName: "Plant"), tasks: [])
        plants.append(newPlant)
        return newPlant
    }
    
    // Delete
    @discardableResult func deletePlant(withID id: String) -> Plant? {
        if let indexToDelete = plants.firstIndex(where: {$0.id.uuidString == id}) {
            let plantToDelete = plants[indexToDelete]
            plants.remove(at: indexToDelete)
            return plantToDelete
        }
        
        return nil
    }
}
