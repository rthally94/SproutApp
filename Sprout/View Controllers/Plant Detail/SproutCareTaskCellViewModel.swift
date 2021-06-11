//
//  SproutCareTaskCellViewModel.swift
//  Sprout
//
//  Created by Ryan Thally on 6/9/21.
//

import UIKit

struct SproutCareTaskCellViewModel {
    let title: String?
    let subtitle: String?
    let image: UIImage?

    init(title: String?, subtitle: String?, image: UIImage?) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }

    init(careTask: SproutCareTaskMO) {
        let formatter = Utility.careScheduleFormatter
        let scheduleText = formatter.string(for: careTask.schedule)

        self.init(title: careTask.taskTypeProperties?.displayName, subtitle: scheduleText, image: careTask.taskTypeProperties?.icon)
    }
}
