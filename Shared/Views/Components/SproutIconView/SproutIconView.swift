//
//  SproutIconView.swift
//  Sprout
//
//  Created by Ryan Thally on 2/17/21.
//

import UIKit
import CoreGraphics

class SproutIconView: UIView {
    func defaultConfiguration() -> SproutIconConfiguration {
        return SproutIconConfiguration()
    }

    var configuration: SproutIconConfiguration {
        get {
            appliedIconConfiguration
        }
        set {
            guard newValue != appliedIconConfiguration else { return }
            applyConfiguration(newValue)
        }
    }

    private lazy var appliedIconConfiguration: SproutIconConfiguration = defaultConfiguration()
    private lazy var aspectConstraint = widthAnchor.constraint(equalTo: heightAnchor)

    private let contentView = UIImageView(frame: .zero)
    private func applyConfiguration(_ newConfiguration: SproutIconConfiguration) {
        // Update to the new View
        switch configuration.iconType {
        case .image:
            contentView.contentMode = .scaleAspectFill
            contentView.tintColor = .clear
        default:
            contentView.contentMode = .scaleAspectFit
            contentView.tintColor = configuration.iconColor
        }

        contentView.image = configuration.image
    }

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraintsIfNeeded()
        applyConfiguration(defaultConfiguration())
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupConstraintsIfNeeded()
        applyConfiguration(defaultConfiguration())
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        applyLayoutMarginsMargins()
        applyCornerRadius()
        applyGradientBackground()
        backgroundColor = configuration.tintColor
    }

    private func setupConstraintsIfNeeded() {
        if aspectConstraint.isActive == false {
            aspectConstraint.isActive = true
        }

        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.pinToLayoutMarginsOf(self)
    }
}

extension SproutIconView {
    private func applyLayoutMarginsMargins() {
        switch configuration.iconType {
        case .image:
            directionalLayoutMargins = .zero
        default:
            let widthInset = (bounds.width * 0.4) / 2
            let heightInset = (bounds.height * 0.4) / 2
            directionalLayoutMargins = .init(top: heightInset, leading: widthInset, bottom: heightInset, trailing: widthInset)
        }
//        setNeedsLayout()
    }

    private func applyCornerRadius() {
        self.clipsToBounds = true
        self.layer.cornerRadius = configuration.cornerRadius(rect: bounds)
    }

    private func applyGradientBackground() {
        // Apply gradient to background
        let gradient = configuration.gradientBackground
        gradient.frame = bounds
        layer.insertSublayer(gradient, at: 0)
    }

    private func applyDropShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 1
        layer.shadowOffset = CGSize(width: 2, height: 2)

        let cornerRadius = configuration.cornerRadius(rect: bounds)
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
}
