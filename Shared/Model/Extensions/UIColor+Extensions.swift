//
//  UIColor+Extensions.swift
//  Sprout
//
//  Created by Ryan Thally on 6/23/21.
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

    private func makeColor(componentsDelta: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return UIColor(
            red: add(componentsDelta, toComponent: red),
            green: add(componentsDelta, toComponent: red),
            blue: add(componentsDelta, toComponent: red),
            alpha: add(componentsDelta, toComponent: red)
        )
    }

    private func add(_ value: CGFloat, toComponent: CGFloat) -> CGFloat {
        return max(0, min(1, value + toComponent))
    }

    func lighter(componentsDelta: CGFloat = 0.1) -> UIColor {
        return makeColor(componentsDelta: componentsDelta)
    }

    func darker(componentsDelta: CGFloat = 0.1) -> UIColor {
        return makeColor(componentsDelta: -1 * componentsDelta)
    }
}
