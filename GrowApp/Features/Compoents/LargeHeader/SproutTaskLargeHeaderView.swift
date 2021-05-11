//
//  SproutTaskLargeHeaderView.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/16/21.
//

import UIKit

class SproutTaskLargeHeaderView: LargeHeaderView {
    var careInfo: CareInfo? {
        didSet {
            applyTaskPropertiesIfAble()
        }
    }

    private func applyTaskPropertiesIfAble() {
        guard let careInfo = careInfo else { return }
        imageView.image = careInfo.careCategory?.icon?.image
        titleLabel.text = careInfo.careCategory?.name?.capitalized
        subtitleLabel.text = careInfo.careSchedule?.recurrenceRule?.intervalText()
    }
}
