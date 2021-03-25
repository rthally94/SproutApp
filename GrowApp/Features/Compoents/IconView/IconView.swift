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
    
    var scaleMode: ScaleMode {
        switch icon {
        case .symbol:
            return .padded(multiplier: 0.6, points: 0)
        default:
            return .full
        }
    }
    
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
        case let .symbol(symbolName, _, _):
            return UIImage(systemName: symbolName)
        case let .image(image):
            return image
        default:
            return nil
        }
    }
    
    var imageContentMode: UIView.ContentMode {
        switch icon {
        case .symbol:
            return .scaleAspectFit
        case .image:
            return .scaleAspectFill
        default:
            return .center
        }
    }
    
    var tintColor: UIColor? {
        switch icon {
        case let .symbol(_, foregroundColor, _) where foregroundColor != nil:
            return foregroundColor
        case let .symbol(_, _, backgroundColor):
            return backgroundColor?.withAlphaComponent(1.0)
        default:
            return nil
        }
    }
    
    var backgroundColor: UIColor? {
        switch icon {
        case let .symbol(_, _, backgroundColor):
            return backgroundColor?.withAlphaComponent(0.5)
        default:
            return nil
        }
    }
    
    func imageInsets(rect: CGRect) -> UIEdgeInsets {
        switch scaleMode {
        case let .padded(multiplier, _):
            let widthInset = (rect.width * multiplier) / 2
            let heightInset = (rect.height * multiplier) / 2
            return UIEdgeInsets(top: -heightInset, left: -widthInset, bottom: -heightInset, right: -widthInset)
        default:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
        }
    }
}

class IconView: UIView {
    func defaultConfiguration() -> IconConfiguration {
        let icon: Icon = .symbol(name: "exclamationmark.triangle", foregroundColor: nil, backgroundColor: .systemGray)
        return IconConfiguration(icon: icon, cornerMode: .circle)
    }
    
    private var appliedIconConfiguration: IconConfiguration?
    var iconViewConfiguration: IconConfiguration? {
        didSet {
            setNeedsLayout()
        }
    }
    
    private var appliedBounds: CGRect?
    
    private lazy var fullConstraint = imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0)
    private lazy var scaledConstraint = imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6)
        
    lazy var imageView = UIImageView()
    
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
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            fullConstraint
        ])
    }
    
    private func configureView() {
        guard iconViewConfiguration != appliedIconConfiguration || bounds != appliedBounds else { return }
        let config = iconViewConfiguration ?? defaultConfiguration()
        
        // Configure CornerStyle
        layer.cornerRadius = config.cornerRadius(rect: bounds)
        clipsToBounds = true
        
        // Configure Icon
        imageView.contentMode = config.imageContentMode
        imageView.image = config.image
        if case .padded = config.scaleMode {
            fullConstraint.isActive = false
            scaledConstraint.isActive = true
        } else {
            scaledConstraint.isActive = false
            fullConstraint.isActive = true
        }
        
        // Colors
        tintColor = config.tintColor
        backgroundColor = config.backgroundColor
        
        appliedIconConfiguration = config
        appliedBounds = bounds
    }
}
