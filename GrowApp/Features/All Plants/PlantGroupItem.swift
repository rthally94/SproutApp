//
//  PlantGroupItem.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/5/21.
//

import UIKit

struct PlantGroupItem: Hashable {
    let plant: SproutPlant

    var image: UIImage? {
        return plant.icon?.image
    }

    var title: String? {
        return plant.name
    }
}
