//
//  LargeHeaderCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/19/21.
//

import UIKit

class LargeHeaderCell: UICollectionViewCell {
    var titleIcon: String? {
        set { largeHeaderView.titleLabel.icon = newValue }
        get { largeHeaderView.titleLabel.icon }
    }

    var titleText: String? {
        set { largeHeaderView.titleLabel.text = newValue }
        get { largeHeaderView.titleLabel.text }
    }

    var valueIcon: String? {
        set { largeHeaderView.subtitleLabel.icon = newValue }
        get { largeHeaderView.subtitleLabel.icon }
    }

    var valueText: String? {
        set { largeHeaderView.subtitleLabel.text = newValue }
        get { largeHeaderView.subtitleLabel.text }
    }

    override var tintColor: UIColor! {
        set { largeHeaderView.backgroundColor = newValue }
        get { largeHeaderView.backgroundColor }
    }

    private var largeHeaderView = LargeHeaderView()

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

        contentView.addSubview(largeHeaderView)
        largeHeaderView.translatesAutoresizingMaskIntoConstraints = false

        let constraints = (
            headerTop: largeHeaderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerLeading: largeHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerBottom: largeHeaderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            headerTrailing: largeHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
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
