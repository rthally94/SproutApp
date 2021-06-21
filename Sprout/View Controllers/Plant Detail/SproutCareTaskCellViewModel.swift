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

    init(careTask task: SproutCareTaskMO) {
        let name = task.careInformation?.type?.capitalized ?? "TASK TYPE NAME"
        let icon = task.careInformation?.iconImage
        let formatter = Utility.careScheduleFormatter
        let scheduleText = formatter.string(for: task.schedule)

        self.init(title: name, subtitle: scheduleText, image: icon)
    }
}
