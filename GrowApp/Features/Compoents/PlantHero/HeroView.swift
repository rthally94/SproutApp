//
//  PlantHeroView.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/26/21.
//

import UIKit

class HeroView: UIView {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        return label
    }()

    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()

    lazy private var headerStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .center

        view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        view.isLayoutMarginsRelativeArrangement = true

        view.blurBackground(style: .prominent)
        view.clipsToBounds = true
        view.layer.cornerRadius = 10

        return view
    }()

    var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        addSubview(imageView)
        addSubview(headerStack)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        imageView.pinToBoundsOf(self)
        NSLayoutConstraint.activate([
            headerStack.widthAnchor.constraint(equalTo: layoutMarginsGuide.widthAnchor, multiplier: 2/3),
            headerStack.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
            headerStack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -16),
            headerStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            headerStack.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: layoutMarginsGuide.topAnchor, multiplier: 1.0)
        ])
    }
}
