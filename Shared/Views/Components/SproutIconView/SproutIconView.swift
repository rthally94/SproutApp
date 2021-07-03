//
//  SproutIconView.swift
//  Sprout
//
//  Created by Ryan Thally on 2/17/21.
//

import UIKit
import CoreGraphics

struct SproutIconConfiguration: Hashable {
    private static let placeholderImage = UIImage.PlaceholderPlantImage
    private static let placeholderColor = UIColor.systemGray
    private static let placeholderSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .largeTitle)

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
    
    var cornerStyle: SproutIconView.CornerStyle = .circle
    
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
            gradient.colors = [color.cgColor, color.cgColor]
        }
        return gradient
    }
}

class SproutIconView: UIView {
    enum CornerStyle: Hashable {
        case circle
        case roundedRect
        case none
    }
    
    func defaultConfiguration() -> SproutIconConfiguration {
        return SproutIconConfiguration()
    }
    
    private var appliedIconConfiguration: SproutIconConfiguration?
    var configuration: SproutIconConfiguration? {
        didSet {
            setNeedsLayout()
        }
    }
    
    private var appliedBounds: CGRect?
    
    private lazy var imageIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var symbolIconView = SproutSymbolSymbolIconView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHiearchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureView()
    }
    
    func configureHiearchy() {
        symbolIconView.translatesAutoresizingMaskIntoConstraints = false
        imageIconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(symbolIconView)
        addSubview(imageIconView)

        symbolIconView.pinToBoundsOf(self)
        imageIconView.pinToBoundsOf(self)

        let aspectConstraint = widthAnchor.constraint(equalTo: heightAnchor)
        aspectConstraint.isActive = true
    }
    
    private func configureView() {
        guard configuration != appliedIconConfiguration || bounds != appliedBounds else { return }
        let config = configuration ?? defaultConfiguration()
        
        // Configure CornerStyle
        layer.cornerRadius = config.cornerRadius(rect: bounds)
        clipsToBounds = true
        
        // Configure Icon
        if let image = config.image, !image.isSymbolImage {
            // Apply image parameters
            imageIconView.image = config.image
            imageIconView.isHidden = false
            symbolIconView.isHidden = true
        } else {
            // Apply SF Symbol parameters
            symbolIconView.image = config.image
            symbolIconView.tintColor = config.iconColor
            let gradient = config.gradientBackground
            gradient.frame = layer.bounds
            symbolIconView.layer.insertSublayer(gradient, at: 0)
            imageIconView.isHidden = true
            symbolIconView.isHidden = false
        }
        
        appliedIconConfiguration = config
        appliedBounds = bounds
    }
}
