//
//  StatisticCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/17/21.
//

import UIKit

class StatisticCell: UICollectionViewCell {
    var title: String? {
        get { statisticView.titleLabel.text }
        set { statisticView.titleLabel.text = newValue }
    }

    var value: String? {
        get { statisticView.valueLabel.text }
        set { statisticView.valueLabel.text = newValue }
    }

    var unit: String? {
        get { statisticView.unitLabel.text }
        set { statisticView.unitLabel.text = newValue }
    }

    var image: UIImage? {
        get { statisticView.imageView.image }
        set { statisticView.imageView.image = newValue }
    }

    override var tintColor: UIColor! {
        get { statisticView.tintColor }
        set { statisticView.tintColor = newValue }
    }

    private let statisticView = StatisticView()

    override func layoutSubviews() {
        super.layoutSubviews()

        setupViewsIfNeeded()
    }

    private func setupViewsIfNeeded() {
        statisticView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statisticView)
        statisticView.pinToBoundsOf(contentView)
    }
}
