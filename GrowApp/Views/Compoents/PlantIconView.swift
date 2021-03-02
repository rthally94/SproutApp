//
//  PlantIconImageView.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/17/21.
//

import UIKit
import CoreGraphics

class PlantIconView: UIView {
    var appliedIcon: PlantIcon?
    var appliedScaleMode: ScaleMode?
    
    enum CornerMode: Hashable {
        case circle
        case roundedRect
        case none
    }
    
    enum ScaleMode: Hashable {
        case padded(multiplier: CGFloat, points: CGFloat)
        case full
    }
    
    private lazy var imageView = UIImageView()
    
    private lazy var fullConstraints: [NSLayoutConstraint] = [
        imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0)
    ]
    
    private lazy var scaledConstraints: [NSLayoutConstraint] = [
        imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6)
    ]
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    convenience init(icon: PlantIcon) {
        self.init(frame: .zero)
        
        setIcon(icon)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHiearchy()
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = min(frame.width, frame.height) / 2
    }
    
    func setIcon(_ newIcon: PlantIcon) {
        guard newIcon != appliedIcon else { return }
        appliedIcon = newIcon
        
        switch appliedIcon {
        case let .symbol(name, foregroundColor, backgroundColor):
            imageView.image = UIImage(systemName: name)
            imageView.contentMode = .scaleAspectFit
            tintColor = foregroundColor ?? backgroundColor?.withAlphaComponent(1.0)
            self.backgroundColor = backgroundColor?.withAlphaComponent(0.5)
            setScaleMode(to: .padded(multiplier: 0.6, points: 0))
        case let .image(image):
            self.imageView.image = image
            imageView.contentMode = .scaleAspectFill
            setScaleMode(to: .full)
        default:
            self.imageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
            imageView.contentMode = .scaleAspectFit
            setScaleMode(to: .full)
        }
    }
    
    func setScaleMode(to newMode: ScaleMode) {
        guard newMode != appliedScaleMode else { return }
        appliedScaleMode = newMode
        
        switch appliedScaleMode {
        case let .padded(multiplier, points):
            let activeConstraints = scaledConstraints + fullConstraints
            NSLayoutConstraint.deactivate(activeConstraints)
            
            scaledConstraints = [
                imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: multiplier, constant: points),
            ]
            
            NSLayoutConstraint.activate(scaledConstraints)
        case .full:
            NSLayoutConstraint.deactivate(scaledConstraints)
            NSLayoutConstraint.activate(fullConstraints)
        case .none:
            NSLayoutConstraint.deactivate(scaledConstraints)
            NSLayoutConstraint.activate(fullConstraints)
        }
    }
}

extension PlantIconView {
    private func configureHiearchy() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(imageView)
        
        let constraints = [
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
        ] + fullConstraints
        
        NSLayoutConstraint.activate(constraints)
    }
}
