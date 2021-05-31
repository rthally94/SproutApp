//
//  LargeHeaderView.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/16/21.
//

import UIKit

class LargeHeaderView: UIView {
    static let titleFont = UIFont.preferredFont(forTextStyle: .largeTitle)
    static let valueFont = UIFont.preferredFont(forTextStyle: .footnote)

    lazy var titleLabel: SproutLabel = {
        let label = SproutLabel()
        label.font = Self.titleFont
        return label
    }()

    lazy var subtitleLabel: SproutLabel = {
        let view = SproutLabel()
        view.font = Self.valueFont
        return view
    }()

    override var backgroundColor: UIColor? {
        didSet {
            let textColor = UIColor.labelColor(against: backgroundColor)
            titleLabel.tintColor = textColor
            subtitleLabel.tintColor = textColor
        }
    }

    private var appliedBounds: CGRect? = nil

    override func layoutSubviews() {
        super.layoutSubviews()

        layoutIfAble()
    }
}

private extension LargeHeaderView {
    func layoutIfAble() {
        guard appliedBounds == nil || appliedBounds != bounds else { return }

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

            subtitleLabel.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1.0),
            subtitleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        ])


    }
}
