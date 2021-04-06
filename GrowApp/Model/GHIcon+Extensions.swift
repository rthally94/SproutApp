//
//  GHIcon+Extensions.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/1/21.
//

import UIKit

extension GHIcon {
    var color: UIColor? {
        if let hexColor = hexColor {
            return UIColor(hex: hexColor)
        }
        
        return nil
    }
    
    var image: UIImage? {
        get {
            if let imageData = imageData {
                return UIImage(data: imageData)
            } else if let symbolName = symbolName, let symbol = UIImage(systemName: symbolName) {
                return symbol
            } else {
                return nil
            }
        }
    }
}
