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
        let aLuma = UIColor.luminance(a)
        let bLuma = UIColor.luminance(b)
        
        let luminanceDarker = min(aLuma, bLuma)
        let luminanceLighter = max(aLuma, bLuma)
        
        return (luminanceLighter + 0.05) / (luminanceDarker + 0.05)
    }
    
    static func luminance(_ color: UIColor) -> CGFloat {
        var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) = (red: 0, green: 0, blue: 0, alpha: 0)
        color.getRed(&components.red, green: &components.green, blue: &components.blue, alpha: &components.alpha)
        let luma = ((0.299 * components.red) + (0.587 * components.green) + (0.114 * components.blue)) / 255
        return luma
    }
    
    static func labelColor(against backgroundColor: UIColor?) -> UIColor {
        guard let backgroundColor = backgroundColor else { return .label }
        
        let lightContrast = UIColor.contrast(backgroundColor, UIColor.lightText)
        let darkContrast = UIColor.contrast(backgroundColor, UIColor.darkText)
        
        return lightContrast > darkContrast ? UIColor.lightText : UIColor.darkText
    }
}
 
