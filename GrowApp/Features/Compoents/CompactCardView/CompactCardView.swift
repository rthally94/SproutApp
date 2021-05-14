//
//  TaskCardView.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/16/21.
//

import UIKit

class CompactCardView: UIView {
    static let titleFont = UIFont.preferredFont(forTextStyle: .headline)
    static let valueFont = UIFont.preferredFont(forTextStyle: .subheadline)

    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.preferredSymbolConfiguration = .init(font: CompactCardView.titleFont)
        view.tintColor = tintColor

        let HCHP = view.contentHuggingPriority(for: .horizontal) + 1
        view.setContentHuggingPriority(HCHP, for: .horizontal)

        return view
    }()

    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = CompactCardView.titleFont
        view.textColor = tintColor
        return view
    }()

    lazy var valueLabel: UILabel = {
        let view = UILabel()
        view.font = CompactCardView.valueFont
        return view
    }()

    private var appliedBounds: CGRect? = nil

    override func layoutSubviews() {
        super.layoutSubviews()

        layoutViewsIfNeeded()
        backgroundColor = UIColor.secondarySystemGroupedBackground
    }
}

private extension CompactCardView {
    func layoutViewsIfNeeded() {
        guard appliedBounds == nil || appliedBounds != bounds else { return }

        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(valueLabel)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            imageView.firstBaselineAnchor.constraint(equalTo: titleLabel.firstBaselineAnchor),

            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: imageView.trailingAnchor, multiplier: 1.0),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

            valueLabel.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1.0),
            valueLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        ])
    }
}
