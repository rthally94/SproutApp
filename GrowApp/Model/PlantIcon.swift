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
    case emoji(String, foregroundColor: UIColor?, backgroundColor: UIColor?)
    case text(String, foregroundColor: UIColor?, backgroundColor: UIColor?)
    case symbol(name: String, foregroundColor: UIColor?, backgroundColor: UIColor?)
}
