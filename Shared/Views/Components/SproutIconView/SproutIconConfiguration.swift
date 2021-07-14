//
//  SproutIconConfiguration.swift
//  Sprout
//
//  Created by Ryan Thally on 7/12/21.
//

import UIKit

struct SproutIconConfiguration: Hashable {
    private static let placeholderImage = UIImage.PlaceholderPlantImage
    private static let placeholderColor = UIColor.systemGray
    private static let placeholderSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .largeTitle)

    enum CornerStyle {
        case circle
        case roundedRect
        case none
    }

    enum IconType {
        case image
        case symbol
    }

    var iconType: IconType {
        if image?.isSymbolImage == true {
            return .symbol
        } else {
            return .image
        }
    }

    var image: UIImage? = SproutIconConfiguration.placeholderImage {
        didSet {
            if image == nil {
                image = SproutIconConfiguration.placeholderImage
            }
        }
    }

    var symbolConfiguration: UIImage.SymbolConfiguration? = SproutIconConfiguration.placeholderSymbolConfiguration {
        didSet {
            if symbolConfiguration == nil {
                symbolConfiguration = SproutIconConfiguration.placeholderSymbolConfiguration
            }
        }
    }

    var tintColor: UIColor? = SproutIconConfiguration.placeholderColor {
        didSet {
            if tintColor == nil {
                tintColor = SproutIconConfiguration.placeholderColor
            }
        }
    }

    var cornerStyle: CornerStyle = .circle
    func cornerRadius(rect: CGRect) -> CGFloat {
        switch cornerStyle {
        case .circle:
            return min(rect.width, rect.height) / 2
        case .roundedRect:
            return min(rect.width, rect.height) / 5
        default:
            return 0
        }
    }

    var iconColor: UIColor {
        return UIColor.labelColor(against: tintColor)
    }

    var gradientBackground: CAGradientLayer {
        let gradient = CAGradientLayer()
        if let color = tintColor {
            gradient.colors = [color.lighter().cgColor, color.darker().cgColor]
        }
        return gradient
    }
}
