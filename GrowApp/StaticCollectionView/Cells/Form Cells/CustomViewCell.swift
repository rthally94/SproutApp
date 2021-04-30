//
//  CustomViewCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/20/21.
//

import UIKit

class CustomViewCell: UICollectionViewCell {
    var customView: UIView? {
        didSet {
            guard customView != oldValue else { return }
            contentView.subviews.forEach {
                $0.removeFromSuperview()
            }
            customConstraints = nil

            setNeedsLayout()

        }
    }

    private var customConstraints: (
        top: NSLayoutConstraint,
        leading: NSLayoutConstraint,
        bottom: NSLayoutConstraint,
        trailing: NSLayoutConstraint
    )?

    override func layoutSubviews() {
        super.layoutSubviews()

        setupViewsIfNeeded()
    }

    func setupViewsIfNeeded() {
        guard customConstraints == nil, let customView = customView else { return }

        contentView.addSubview(customView)
        customView.translatesAutoresizingMaskIntoConstraints = false

        let constraints = (
            top: customView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            leading: customView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            bottom: customView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            trailing: customView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        )

        NSLayoutConstraint.activate([
            constraints.top,
            constraints.leading,
            constraints.bottom,
            constraints.trailing
        ])

        customConstraints = constraints
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        customView = nil
    }
}
