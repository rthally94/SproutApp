//
//  PlantIcon.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/17/21.
//

import Foundation
import UIKit

enum PlantIcon: Hashable {
    case image(UIImage)
    case emoji(String, backgroundColor: UIColor)
    case text(String, backgroundColor: UIColor)
    case symbol(name: String, backgroundColor: UIColor)
}
