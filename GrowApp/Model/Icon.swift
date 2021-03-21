//
//  PlantIcon.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/17/21.
//

import UIKit

enum Icon: Hashable {
    case image(UIImage?)
    case symbol(name: String, foregroundColor: UIColor?, backgroundColor: UIColor?)
    
    var image: UIImage? {
        switch self {
        case let .image(image):
            return image
        case let .symbol(name, foregroundColor, _):
            return UIImage(systemName: name)?.withTintColor(foregroundColor ?? .label)
        }
    }
}
