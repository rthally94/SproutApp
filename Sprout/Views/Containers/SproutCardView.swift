//
//  SproutCardView.swift
//  Sprout
//
//  Created by Ryan Thally on 4/28/21.
//

import UIKit

class SproutCardView: UIView {
    let plantIconView = SproutIconView()

    let textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        return label
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
        addSubview(plantIconView)
        addSubview(textLabel)

        plantIconView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            plantIconView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            plantIconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            plantIconView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.75),

            textLabel.topAnchor.constraint(equalToSystemSpacingBelow: plantIconView.bottomAnchor, multiplier: 1.0),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}
