//
//  PlantType.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/17/21.
//

import Foundation
import UIKit

struct PlantType: Identifiable, Equatable, Hashable {
    var id: UUID = UUID()
    var scientificName: String
    var commonName: String

    static var previousChoices: Set<PlantType> = []
}

extension PlantType {
    static let allTypes: [PlantType] = [
        PlantType(scientificName: "Ficus Lyrata", commonName: "Fiddle Leaf Fig"),
        PlantType(scientificName: "Pilea Peperomiodies", commonName: "Chinese Money Plant"),
        PlantType(scientificName: "Chlorophytum Comosum", commonName: "Spider Plant"),
        PlantType(scientificName: "Spathiphyllum Wallisii", commonName: "Peace Lily"),
        PlantType(scientificName: "Tillandsia", commonName: "Air Plant"),
        PlantType(scientificName: "Aloe Barbadensis", commonName: "Aloe Vera"),
        PlantType(scientificName: "Crassula Ovata", commonName: "Jade Plant"),
        PlantType(scientificName: "Saintpaulia", commonName: "African Violet"),
        PlantType(scientificName: "Sansevieria Trifasciata", commonName: "Snake Plant"),
        PlantType(scientificName: "Bromeliaceae", commonName: "Bromeliad"),
        PlantType(scientificName: "Dracaena Sanderiana", commonName: "Lucky Bamboo"),
        PlantType(scientificName: "Hedera Helix", commonName: "Ivy"),
        PlantType(scientificName: "Dieffenbachia", commonName: "Dumb Cane Plant"),
        PlantType(scientificName: "Ocimum Basilicum", commonName: "Basil"),
        PlantType(scientificName: "Schefflera", commonName: "Umbrella Plant"),
        PlantType(scientificName: "Codiaeum", commonName: "Croton"),
        PlantType(scientificName: "Philodendron Scandens", commonName: "Philodendron"),
    ]
}
