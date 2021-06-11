//
//  LargeHeaderCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/19/21.
//

import UIKit

class SproutCareDetailCell: UICollectionViewCell {
    var titleIcon: String? {
        set { careDetailView.titleLabel.icon = newValue }
        get { careDetailView.titleLabel.icon }
    }

    var titleImage: UIImage? {
        set { careDetailView.titleLabel.image = newValue }
        get { careDetailView.titleLabel.image }
    }

    var titleText: String? {
        set { careDetailView.titleLabel.text = newValue }
        get { careDetailView.titleLabel.text }
    }

    var valueIcon: String? {
        set { careDetailView.subtitleLabel.icon = newValue }
        get { careDetailView.subtitleLabel.icon }
    }

    var valueText: String? {
        set { careDetailView.subtitleLabel.text = newValue }
        get { careDetailView.subtitleLabel.text }
    }

    override var tintColor: UIColor! {
        set { careDetailView.backgroundColor = newValue }
        get { careDetailView.backgroundColor }
    }

    private var careDetailView = SproutCareDetailView()

    private var customConstraints: (
        headerTop: NSLayoutConstraint,
        headerLeading: NSLayoutConstraint,
        headerBottom: NSLayoutConstraint,
        headerTrailing: NSLayoutConstraint
    )?

    override func layoutSubviews() {
        super.layoutSubviews()

        setupViewsIfNeeded()
    }

    private func setupViewsIfNeeded() {
        guard customConstraints == nil else { return }

        contentView.addSubview(careDetailView)
        careDetailView.translatesAutoresizingMaskIntoConstraints = false

        let constraints = (
            headerTop: careDetailView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerLeading: careDetailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerBottom: careDetailView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            headerTrailing: careDetailView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        )

        NSLayoutConstraint.activate([
            constraints.headerTop,
            constraints.headerLeading,
            constraints.headerBottom,
            constraints.headerTrailing
        ])

        customConstraints = constraints
    }
}
