//
//  StatisticView.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/17/21.
//

import UIKit

class StatisticView: UIView {
    static let titleFont = UIFont.preferredFont(forTextStyle: .subheadline)
    static let valueFont = UIFont.preferredFont(forTextStyle: .title2)
    static let unitFont = UIFont.preferredFont(forTextStyle: .footnote)

    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = tintColor
        return view
    }()

    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = StatisticView.titleFont
        view.tintColor = tintColor
        return view
    }()

    lazy var valueLabel: UILabel = {
        let view = UILabel()
        view.font = StatisticView.valueFont
        return view
    }()

    lazy var unitLabel: UILabel = {
        let view = UILabel()
        view.font = StatisticView.unitFont
        return view
    }()

    private var appliedBounds: CGRect? = nil

    override func layoutSubviews() {
        super.layoutSubviews()

        layoutViewsIfNeeded()
    }

    private func layoutViewsIfNeeded() {
        guard appliedBounds == nil || appliedBounds != bounds else { return }

        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        unitLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(unitLabel)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: valueLabel.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: imageView.trailingAnchor, multiplier: 1.0),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

            valueLabel.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1.0),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),

            unitLabel.leadingAnchor.constraint(equalTo: valueLabel.trailingAnchor),
            unitLabel.firstBaselineAnchor.constraint(equalTo: valueLabel.firstBaselineAnchor),
            unitLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        ])
    }
}
