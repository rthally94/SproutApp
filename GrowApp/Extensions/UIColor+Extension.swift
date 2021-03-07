//
//  UIColor+Extension.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/4/21.
//

import UIKit

extension UIColor {
    
    /// Calculates the contrast ratio using "relative luminance".
    /// - Parameters:
    ///   - a: The first color
    ///   - b: The second color
    /// - Returns: The constast ratio "X:1"
    static func contrast(_ a: UIColor, _ b: UIColor) -> CGFloat {
        var L1: CGFloat = 0.0
        var L2: CGFloat = 0.0
        
        a.getHue(nil, saturation: nil, brightness: &L1, alpha: nil)
        b.getHue(nil, saturation: nil, brightness: &L2, alpha: nil)
        
        if L1 > L2 {
            return (L1 + 0.05) / (L2 + 0.05)
        } else {
            return (L2 + 0.05) / (L1 + 0.05)
        }
    }
    
    static func labelColor(against backgroundColor: UIColor?) -> UIColor {
        guard let backgroundColor = backgroundColor else { return .label }
        
        let lightContrast = UIColor.contrast(backgroundColor, UIColor.lightText)
        let darkContrast = UIColor.contrast(backgroundColor, UIColor.darkText)
        
        return lightContrast > darkContrast ? UIColor.lightText : UIColor.darkText
    }
}
 
