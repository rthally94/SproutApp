//
//  PlantType.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/17/21.
//

import Foundation
import UIKit

public struct SproutPlantTemplate: Identifiable, Equatable, Hashable {
    public var id: UUID = UUID()
    public var scientificName: String
    public var commonName: String
}

public extension SproutPlantTemplate {
    static let allTypes: [SproutPlantTemplate] = [
        SproutPlantTemplate(scientificName: "Ficus Lyrata", commonName: "Fiddle Leaf Fig"),
        SproutPlantTemplate(scientificName: "Pilea Peperomiodies", commonName: "Chinese Money Plant"),
        SproutPlantTemplate(scientificName: "Chlorophytum Comosum", commonName: "Spider Plant"),
        SproutPlantTemplate(scientificName: "Spathiphyllum Wallisii", commonName: "Peace Lily"),
        SproutPlantTemplate(scientificName: "Tillandsia", commonName: "Air Plant"),
        SproutPlantTemplate(scientificName: "Aloe Barbadensis", commonName: "Aloe Vera"),
        SproutPlantTemplate(scientificName: "Crassula Ovata", commonName: "Jade Plant"),
        SproutPlantTemplate(scientificName: "Saintpaulia", commonName: "African Violet"),
        SproutPlantTemplate(scientificName: "Sansevieria Trifasciata", commonName: "Snake Plant"),
        SproutPlantTemplate(scientificName: "Bromeliaceae", commonName: "Bromeliad"),
        SproutPlantTemplate(scientificName: "Dracaena Sanderiana", commonName: "Lucky Bamboo"),
        SproutPlantTemplate(scientificName: "Hedera Helix", commonName: "Ivy"),
        SproutPlantTemplate(scientificName: "Dieffenbachia", commonName: "Dumb Cane Plant"),
        SproutPlantTemplate(scientificName: "Ocimum Basilicum", commonName: "Basil"),
        SproutPlantTemplate(scientificName: "Schefflera", commonName: "Umbrella Plant"),
        SproutPlantTemplate(scientificName: "Codiaeum", commonName: "Croton"),
        SproutPlantTemplate(scientificName: "Philodendron Scandens", commonName: "Philodendron"),
    ].sorted { lhs, rhs in
        lhs.commonName < rhs.commonName
    }

    static let sampleData: [SproutPlantTemplate] = [
        SproutPlantTemplate(scientificName: "Ficus Lyrata", commonName: "Fiddle Leaf Fig"),
        SproutPlantTemplate(scientificName: "Bromeliaceae", commonName: "Bromeliad"),
        SproutPlantTemplate(scientificName: "Schefflera", commonName: "Umbrella Plant"),
        SproutPlantTemplate(scientificName: "Pilea Peperomiodies", commonName: "Chinese Money Plant"),
    ]

    static func newPlant() -> SproutPlantTemplate {
        SproutPlantTemplate(scientificName: "NEW PLANT", commonName: "NEW PLANT")
    }
}


