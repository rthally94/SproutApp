//
//  SproutButton.swift
//  Sprout
//
//  Created by Ryan Thally on 6/10/21.
//

import UIKit

class SproutCapsuleButton: UIButton {
    static let DefaultColor = UIColor.systemGray.withAlphaComponent(0.5)
    static let SelectedColor = UIColor.white

    private var needsInitialConfig = true

    override func layoutSubviews() {
        super.layoutSubviews()

        if needsInitialConfig {
            titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
            titleLabel?.adjustsFontForContentSizeCategory = true

            setTitleColor(Self.DefaultColor, for: .normal)
            setTitleColor(Self.SelectedColor, for: .selected)
            setTitleColor(Self.SelectedColor, for: .highlighted)

            updateAppearance()
            needsInitialConfig = false
        }

        if bounds.height > bounds.width {
            frame = CGRect(x: frame.minX, y: frame.minY, width: frame.height, height: frame.height)
        }

        clipsToBounds = true
        layer.cornerRadius = bounds.height/2.0
    }

    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            updateAppearance()
        }
    }

    private func updateAppearance() {
        switch (isHighlighted, isSelected) {
        case (false, false):
            // Default
            backgroundColor = .clear
            layer.borderWidth = 2
            layer.borderColor = Self.DefaultColor.cgColor

        case (true, false):
            // Pressed, not selected
            let lighterDefaultColor = Self.DefaultColor.withAlphaComponent(0.25)
            backgroundColor = lighterDefaultColor
            layer.borderWidth = 0
            layer.borderColor = nil

        case (false, true):
            // Selected, not pressed
            backgroundColor = tintColor
            layer.borderWidth = 0
            layer.borderColor = nil

        case (true, true):
            // Selected and pressed
            backgroundColor = tintColor.withAlphaComponent(0.5)
            layer.borderWidth = 0
            layer.borderColor = nil
        }

        titleLabel?.backgroundColor = .clear
    }
}
