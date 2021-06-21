//
//  UIColor+Extension.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/4/21.
//

import UIKit

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(after: hex.startIndex)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    a = 1.0
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            } else if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
    public func hexString() -> String {
        typealias ColorComponents = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
        var components: ColorComponents = (red: 0, green: 0, blue: 0, alpha: 1)
        getRed(&components.red, green: &components.green, blue: &components.blue, alpha: &components.alpha)
        
        return String(format: "#%02X%02X%02X%02X", Int(components.red * 255), Int(components.green * 255), Int(components.blue * 255), Int(components.alpha * 255))
    }
    
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
        typealias ColorComponents = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
        var components: ColorComponents = (red: 0, green: 0, blue: 0, alpha: 0)
        color.getRed(&components.red, green: &components.green, blue: &components.blue, alpha: &components.alpha)
        
        components.red = components.red <= 0.03928 ? components.red/12.92 : pow((components.red+0.055)/1.055, 2.4)
        components.green = components.green <= 0.03928 ? components.green/12.92 : pow((components.green+0.055)/1.055, 2.4)
        components.blue = components.blue <= 0.03928 ? components.blue/12.92 : pow((components.blue+0.055)/1.055, 2.4)
        
        let luma = ((0.2126 * components.red) + (0.7152 * components.green) + (0.0722 * components.blue))
        return luma
    }
    
    static func labelColor(against backgroundColor: UIColor?) -> UIColor {
        guard let backgroundColor = backgroundColor else { return .label }
        
        let lightContrast = UIColor.contrast(backgroundColor, UIColor.lightText)
        let darkContrast = UIColor.contrast(backgroundColor, UIColor.darkText)
        
        if lightContrast > 2 || lightContrast > darkContrast {
            return UIColor.white
        } else {
            return UIColor.darkText
        }
    }
}
 
