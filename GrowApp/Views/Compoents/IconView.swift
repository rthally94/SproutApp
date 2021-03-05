//
//  PlantIconImageView.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/17/21.
//

import UIKit
import CoreGraphics

class IconView: UIImageView {
    private var appliedIcon: Icon?
    private var appliedScaleMode: ScaleMode? = .full
    
    enum CornerMode: Hashable {
        case circle
        case roundedRect
        case none
    }
    
    enum ScaleMode: Hashable {
        case padded(multiplier: CGFloat, points: CGFloat)
        case full
    }
    
    private var cornerRadius: CGFloat?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard cornerRadius == nil else { return }
        
        let radius = min(bounds.width, bounds.height) / 2
        layer.cornerRadius = radius
        clipsToBounds = true
        cornerRadius = radius
    }
    
    func setIcon(_ newIcon: Icon) {
        guard newIcon != appliedIcon else { return }
        appliedIcon = newIcon
        
        switch appliedIcon {
        case let .symbol(name, foregroundColor, backgroundColor):
            image = UIImage(systemName: name)
            contentMode = .scaleAspectFit
            tintColor = foregroundColor ?? backgroundColor?.withAlphaComponent(1.0)
            self.backgroundColor = backgroundColor?.withAlphaComponent(0.5)
            setScaleMode(to: .padded(multiplier: 0.6, points: 0))
        case let .image(newImage):
            image = newImage
            contentMode = .scaleAspectFill
            setScaleMode(to: .full)
        default:
            image = UIImage(systemName: "exclamationmark.triangle.fill")
            contentMode = .scaleAspectFit
            setScaleMode(to: .full)
        }
    }
    
    func setScaleMode(to newMode: ScaleMode) {
        guard newMode != appliedScaleMode else { return }
        appliedScaleMode = newMode
        
        switch appliedScaleMode {
        case let .padded(multiplier, _):
            let widthInset = (bounds.width * multiplier) / 2
            let heightInset = (bounds.height * multiplier) / 2
            let insets = UIEdgeInsets(top: heightInset, left: widthInset, bottom: -heightInset, right: -widthInset)
            image = image?.withAlignmentRectInsets(insets)
        case .full:
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            image = image?.withAlignmentRectInsets(insets)
        case .none:
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            image = image?.withAlignmentRectInsets(insets)
        }
    }
}
