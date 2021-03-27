//
//  PlantIcon.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/17/21.
//

import UIKit

enum Icon: Hashable {
    case image(UIImage?)
    case symbol(name: String, tintColor: UIColor?)
    
    var image: UIImage? {
        switch self {
        case let .image(image):
            return image
        case let .symbol(name, tintColor):
            return UIImage(systemName: name)?.withTintColor(tintColor ?? .label)
        }
    }
    
    var tintColor: UIColor? {
        switch self {
        case .symbol(_, let tintColor):
            return tintColor
        default:
            return nil
        }
    }
}
