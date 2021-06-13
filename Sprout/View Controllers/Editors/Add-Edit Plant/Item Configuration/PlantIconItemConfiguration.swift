//
//  PlantIconItemConfiguration.swift
//  Sprout
//
//  Created by Ryan Thally on 6/11/21.
//

import UIKit

struct PlantIconItemConfiguration: Hashable {
    var image: UIImage?
}

extension PlantIconItemConfiguration {
    init(plant: SproutPlantMO) {
        image = plant.icon
    }
}
