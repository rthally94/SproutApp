//
//  PlantHeroView.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/26/21.
//

import UIKit

class HeroView: UIView {
    var iconView = IconView()
    var headerTextView = HeaderView()

    var backgroundImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.contentScaleFactor = 2.0
        imageView.blurBackground(style: .systemChromeMaterial)
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

    private func setupViews() {
        addSubview(backgroundImageView)
        addSubview(iconView)
        addSubview(headerTextView)

        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        headerTextView.translatesAutoresizingMaskIntoConstraints = false

        backgroundImageView.pinToBoundsOf(self)

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            iconView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
            iconView.widthAnchor.constraint(equalTo: layoutMarginsGuide.widthAnchor, multiplier: 0.5),

            headerTextView.topAnchor.constraint(equalToSystemSpacingBelow: iconView.bottomAnchor, multiplier: 1.0),
            headerTextView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
            headerTextView.widthAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.widthAnchor),
            headerTextView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
}
