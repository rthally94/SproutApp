//
//  SproutHeaderCell.swift
//  Sprout
//
//  Created by Ryan Thally on 6/6/21.
//

import UIKit

class SproutHeaderCell: UICollectionViewCell {
    var headerView = HeaderView()
    private var needsSetup = true

    override func layoutSubviews() {
        super.layoutSubviews()
        setupViewsIfNeeded()
    }

    private func setupViewsIfNeeded() {
        guard needsSetup else { return }

        contentView.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.pinToBoundsOf(contentView)

        needsSetup = false
    }
}
