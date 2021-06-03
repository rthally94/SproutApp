//
//  PlantGroupItem.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/5/21.
//

import UIKit

struct PlantGroupItem: Hashable {
    let plant: SproutPlantMO

    var image: UIImage? {
        return plant.icon
    }

    var title: String? {
        return plant.nickname ?? plant.commonName
    }
}
