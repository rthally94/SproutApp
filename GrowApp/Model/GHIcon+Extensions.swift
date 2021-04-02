//
//  GHIcon+Extensions.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/1/21.
//

import UIKit

extension GHIcon {
    var uicolor: UIColor? {
        if let hexColor = tintColor {
            return UIColor(hex: hexColor)
        }
        
        return nil
    }
    
    var uiimage: UIImage? {
        if let image = image as? UIImage {
            return image
        } else if let symbolName = symbolName, let symbol = UIImage(systemName: symbolName) {
            return symbol
        } else {
            return nil
        }
    }
}
