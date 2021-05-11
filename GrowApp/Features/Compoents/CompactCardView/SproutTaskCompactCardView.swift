//
//  TaskCompactCardView.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/17/21.
//

import UIKit

class SproutTaskCompactCardView: CompactCardView {
    var careInfo: CareInfo? {
        didSet {
            populateCardProperties()
        }
    }

    private func populateCardProperties() {
        imageView.image = careInfo?.careCategory?.icon?.image
        titleLabel.text = careInfo?.careCategory?.name
        valueLabel.text = careInfo?.careSchedule?.recurrenceRule?.intervalText()
    }
}
