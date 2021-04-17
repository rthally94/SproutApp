//
//  TaskCompactCardView.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/17/21.
//

import UIKit

class SproutTaskCompactCardView: CompactCardView {
    var task: GHTask? {
        didSet {
            populateCardProperties()
        }
    }

    private func populateCardProperties() {
        imageView.image = task?.taskType?.icon?.image
        titleLabel.text = task?.taskType?.name
        valueLabel.text = task?.interval?.intervalText()
    }
}
