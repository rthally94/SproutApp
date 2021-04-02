//
//  PlantStore.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/29/21.
//

import Foundation

protocol PlantStore {
    var plants: [Plant] { get }
    
    func addPlant(_ newPlant: Plant)
    @discardableResult func removePlant(_ plant: Plant) -> Plant?
    @discardableResult func removePlant(withID id: Plant.IDType) -> Plant?
    @discardableResult func replacePlant(_ plant: Plant, withPlant newPlant: Plant) -> Plant?
    @discardableResult func replacePlant(withID id: Plant.IDType, withPlant newPlant: Plant) -> Plant?
}

class MemoryPlantStore: PlantStore {
    var plants: [Plant] = []
    
    func addPlant(_ newPlant: Plant) {
        if !plants.contains(newPlant) {
            plants.append(newPlant)
        }
    }
    
    func removePlant(_ plant: Plant) -> Plant? {
        if let indexToRemove = plants.firstIndex(of: plant) {
            return plants.remove(at: indexToRemove)
        } else {
            return nil
        }
    }
    
    func removePlant(withID id: Plant.IDType) -> Plant? {
        if let plant = plants.first(where: {$0.id == id}) {
            return removePlant(plant)
        } else {
            return nil
        }
    }
    
    func replacePlant(_ plant: Plant, withPlant newPlant: Plant) -> Plant? {
        if let indexToReplace = plants.firstIndex(of: plant) {
            plants[indexToReplace] = newPlant
            return newPlant
        } else {
            return nil
        }
    }
    
    func replacePlant(withID id: Plant.IDType, withPlant newPlant: Plant) -> Plant? {
        if let plantToReplace = plants.first(where: {$0.id == id}) {
            return replacePlant(plantToReplace, withPlant: newPlant)
        } else {
            return nil
        }
    }
}
