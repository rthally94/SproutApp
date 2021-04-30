//
//  HeaderCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/17/21.
//

import UIKit

class HeaderCell: UICollectionViewCell {
    static let titleFont = UIFont.preferredFont(forTextStyle: .largeTitle)
    static let subtitleFont = UIFont.preferredFont(forTextStyle: .headline)

    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = HeaderCell.titleFont
        view.textAlignment = .center
        return view
    }()

    lazy var subtitleLabel: UILabel = {
        let view = UILabel()
        view.font = HeaderCell.subtitleFont
        view.textAlignment = .center
        return view
    }()

    private var appliedBounds: CGRect? = nil

    override func layoutSubviews() {
        super.layoutSubviews()

        setupViewsIfNeeded()
    }

    func setupViewsIfNeeded() {
        guard appliedBounds == nil || appliedBounds != bounds else { return }

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 1.0),

            subtitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 0.5),
            subtitleLabel.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
            subtitleLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 1.0),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        appliedBounds = bounds
    }
}
