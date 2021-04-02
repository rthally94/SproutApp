//
//  PlantIconImageView.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/17/21.
//

import UIKit
import CoreGraphics

enum CornerStyle: Hashable {
    case circle
    case roundedRect
    case none
}

struct IconConfiguration: Hashable {
    var icon: GHIcon?
    var cornerMode: CornerStyle?
    
    func cornerRadius(rect: CGRect) -> CGFloat {
        switch cornerMode {
        case .circle:
            return min(rect.width, rect.height) / 2
        case .roundedRect:
            return min(rect.width, rect.height) / 4
        default:
            return 0
        }
    }
    
    var image: UIImage? {
        if let image = icon?.image as? UIImage {
            return image
        } else if let symbolName = icon?.symbolName, let image = UIImage(systemName: symbolName) {
            return image
        } else {
            return UIImage(systemName: "photo.on.rectangle.angled")
        }
    }
    
    var iconColor: UIColor {
        return UIColor.labelColor(against: tintColor)
    }
    
    var tintColor: UIColor {
        if let hexColor = icon?.tintColor, let color = UIColor(hex: hexColor) {
            return color
        } else {
            return .gray
        }
    }
    
    var gradientBackground: CAGradientLayer {
        let gradient = CAGradientLayer()
        let color = tintColor
        gradient.colors = [color.cgColor, color.cgColor]
        return gradient
    }
}

class IconView: UIView {
    func defaultConfiguration() -> IconConfiguration {
        return IconConfiguration(cornerMode: .circle)
    }
    
    private var appliedIconConfiguration: IconConfiguration?
    var iconViewConfiguration: IconConfiguration? {
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
    
    private lazy var symbolIconView = SymbolIconView()
    
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
        addSubview(symbolIconView)
        
        NSLayoutConstraint.activate([
            symbolIconView.widthAnchor.constraint(equalTo: widthAnchor),
            symbolIconView.heightAnchor.constraint(equalTo: symbolIconView.widthAnchor),
            symbolIconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            symbolIconView.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
        
        imageIconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageIconView)
        
        NSLayoutConstraint.activate([
            imageIconView.widthAnchor.constraint(equalTo: widthAnchor),
            imageIconView.heightAnchor.constraint(equalTo: imageIconView.widthAnchor),
            imageIconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageIconView.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
    
    private func configureView() {
        guard iconViewConfiguration != appliedIconConfiguration || bounds != appliedBounds else { return }
        let config = iconViewConfiguration ?? defaultConfiguration()
        
        // Configure CornerStyle
        layer.cornerRadius = config.cornerRadius(rect: bounds)
        clipsToBounds = true
        
        // Configure Icon
        if config.icon?.image != nil {
            imageIconView.image = config.image
        } else if config.icon?.symbolName != nil {
            symbolIconView.image = config.image
        } else {
            symbolIconView.image = config.image
        }
        
        // Colors
        symbolIconView.tintColor = config.iconColor
        let gradient = config.gradientBackground
        gradient.frame = layer.bounds
        symbolIconView.layer.insertSublayer(gradient, at: 0)
        
        appliedIconConfiguration = config
        appliedBounds = bounds
    }
}
