//
//  CompactCardCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/17/21.
//

import UIKit

class CompactCardCell: UICollectionViewCell {
    var title: String? {
        get { compactCardView.titleLabel.text }
        set { compactCardView.titleLabel.text = newValue }
    }

    var value: String? {
        get { compactCardView.valueLabel.text }
        set { compactCardView.valueLabel.text = newValue }
    }

    var image: UIImage? {
        get { compactCardView.imageView.image }
        set { compactCardView.imageView.image = newValue }
    }

    override var tintColor: UIColor! {
        get { compactCardView.tintColor }
        set { compactCardView.tintColor = newValue }
    }

    private var compactCardView = CompactCardView()

    private var appliedBounds: CGRect? = nil

    override func layoutSubviews() {
        super.layoutSubviews()

        setupViewsIfNeeded()
    }

    private func setupViewsIfNeeded() {
        guard appliedBounds == nil || appliedBounds != bounds else { return }

        compactCardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(compactCardView)
        compactCardView.pinToBoundsOf(contentView)

        layer.cornerRadius = 10
        clipsToBounds =  true
        
        appliedBounds = bounds
    }
}
