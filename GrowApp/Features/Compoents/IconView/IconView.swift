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

enum ScaleMode: Hashable {
    case padded(multiplier: CGFloat, points: CGFloat)
    case full
}

struct IconConfiguration: Hashable {
    var icon: Icon?
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
        switch icon {
        case let .image(image):
            return image
        default:
            return nil
        }
    }
    
    var symbolImage: UIImage? {
        switch icon {
        case let .symbol(symbolName, _):
            return UIImage(systemName: symbolName)
        default:
            return nil
        }
    }
    
    var iconColor: UIColor {
        return UIColor.labelColor(against: tintColor)
    }
    
    var tintColor: UIColor? {
        switch icon {
        case let .symbol(_, tintColor):
            return tintColor
        default:
            return nil
        }
    }
    
    var gradientBackground: CAGradientLayer {
        let gradient = CAGradientLayer()
        let color = tintColor ?? .gray
        gradient.colors = [color.cgColor, color.cgColor]
        return gradient
    }
}

class IconView: UIView {
    func defaultConfiguration() -> IconConfiguration {
        let icon: Icon = .symbol(name: "exclamationmark.triangle", tintColor: .systemGray)
        return IconConfiguration(icon: icon, cornerMode: .circle)
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
        imageIconView.image = config.image
        symbolIconView.image = config.symbolImage
        
        // Colors
        symbolIconView.tintColor = config.iconColor
        let gradient = config.gradientBackground
        gradient.frame = layer.bounds
        symbolIconView.layer.insertSublayer(gradient, at: 0)
        
        appliedIconConfiguration = config
        appliedBounds = bounds
    }
}
