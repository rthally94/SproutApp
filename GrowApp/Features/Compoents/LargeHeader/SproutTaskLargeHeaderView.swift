//
//  SproutTaskLargeHeaderView.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/16/21.
//

import UIKit

class SproutTaskLargeHeaderView: LargeHeaderView {
    var task: GHTask? {
        didSet {
            applyTaskPropertiesIfAble()
        }
    }

    private func applyTaskPropertiesIfAble() {
        guard let task = task else { return }

        imageView.image = task.taskType?.icon?.image
        titleLabel.text = task.taskType?.name?.capitalized
        subtitleLabel.text = task.interval?.intervalText()
    }
}
