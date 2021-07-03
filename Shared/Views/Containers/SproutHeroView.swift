//
//  SproutHeroView.swift
//  Sprout
//
//  Created by Ryan Thally on 4/26/21.
//

import UIKit

class SproutHeroView: UIView {
    var iconView = SproutIconView()
    var headerTextView = SproutBlurredHeaderView()

    var backgroundImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.contentScaleFactor = 2.0
        imageView.blurBackground(style: .systemMaterial)
        return imageView
    }()

    private var needsLayout = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        iconView.layer.shadowColor = UIColor.black.cgColor
        iconView.layer.shadowOpacity = 0.25
        iconView.layer.shadowRadius = 1
        iconView.layer.shadowOffset = CGSize(width: 2, height: 2)
    }

    private func setupViews() {
        addSubview(backgroundImageView)
        addSubview(iconView)
        addSubview(headerTextView)

        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        headerTextView.translatesAutoresizingMaskIntoConstraints = false

        backgroundImageView.pinToBoundsOf(self)

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 16),
            iconView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
            iconView.widthAnchor.constraint(equalTo: layoutMarginsGuide.widthAnchor, multiplier: 0.4),

            headerTextView.topAnchor.constraint(equalToSystemSpacingBelow: iconView.bottomAnchor, multiplier: 2.0),
            headerTextView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
            headerTextView.widthAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.widthAnchor),
            headerTextView.bottomAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor, constant: -16)
        ])
    }
}
