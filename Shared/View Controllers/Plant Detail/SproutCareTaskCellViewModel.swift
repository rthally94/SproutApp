//
//  SproutCareTaskCellViewModel.swift
//  Sprout
//
//  Created by Ryan Thally on 6/9/21.
//

import UIKit
import SproutKit

struct SproutCareTaskCellViewModel {
    let title: String?
    let subtitle: String?
    let image: UIImage?

    init(title: String?, subtitle: String?, image: UIImage?) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }

    init(careTask task: SproutCareTaskMO) {
        let name = task.careInformation?.type?.capitalized ?? "TASK TYPE NAME"
        let icon = task.careInformation?.iconImage

        let scheduleText: String
        if let schedule = task.schedule {
            let formatter = Utility.careScheduleFormatter
            scheduleText = formatter.string(from: schedule)
        } else {
            scheduleText = "Any Time"
        }

        self.init(title: name, subtitle: scheduleText, image: icon)
    }
}
