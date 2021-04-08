//
//  PlantIconImageView.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/17/21.
//

import UIKit
import CoreGraphics

struct IconConfiguration: Hashable {
    private static let placeholderImage = UIImage(systemName: "photo.on.rectangle.angled")!
    private static let placeholderColor = UIColor.systemGray
    
    private var backingImage: UIImage?
    var image: UIImage? {
        get {
            return backingImage ?? IconConfiguration.placeholderImage
        }
        set {
            backingImage = newValue
        }
    }
    
    private var backingTintColor: UIColor?
    var tintColor: UIColor? {
        get {
            backingTintColor ?? IconConfiguration.placeholderColor
        }
        set {
            backingTintColor = newValue
        }
    }
    
    var cornerStyle: IconView.CornerStyle = .circle
    
    func cornerRadius(rect: CGRect) -> CGFloat {
        switch cornerStyle {
        case .circle:
            return min(rect.width, rect.height) / 2
        case .roundedRect:
            return min(rect.width, rect.height) / 4
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

class IconView: UIView {
    enum CornerStyle: Hashable {
        case circle
        case roundedRect
        case none
    }
    
    func defaultConfiguration() -> IconConfiguration {
        return IconConfiguration()
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
            symbolIconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            symbolIconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            symbolIconView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor),
            symbolIconView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor),
            symbolIconView.heightAnchor.constraint(equalTo: symbolIconView.widthAnchor),
        ])
        
        imageIconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageIconView)
        
        NSLayoutConstraint.activate([
            imageIconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageIconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageIconView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor),
            imageIconView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor),
            imageIconView.heightAnchor.constraint(equalTo: imageIconView.widthAnchor),
        ])
    }
    
    private func configureView() {
        guard iconViewConfiguration != appliedIconConfiguration || bounds != appliedBounds else { return }
        let config = iconViewConfiguration ?? defaultConfiguration()
        
        // Configure CornerStyle
        layer.cornerRadius = config.cornerRadius(rect: bounds)
        clipsToBounds = true
        
        // Configure Icon
        if let image = config.image, !image.isSymbolImage {
            // Apply image parameters
            imageIconView.image = config.image
        } else {
            // Apply SF Symbol parameters
            symbolIconView.image = config.image
            symbolIconView.tintColor = config.iconColor
            let gradient = config.gradientBackground
            gradient.frame = layer.bounds
            symbolIconView.layer.insertSublayer(gradient, at: 0)
        }
        
        appliedIconConfiguration = config
        appliedBounds = bounds
    }
}
