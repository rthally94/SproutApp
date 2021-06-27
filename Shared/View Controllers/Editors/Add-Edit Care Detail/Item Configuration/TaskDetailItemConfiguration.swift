//
//  TaskDetailHeaderItemConfiguration.swift
//  Sprout
//
//  Created by Ryan Thally on 6/12/21.
//

import UIKit
import SproutKit

struct TaskDetailItemConfiguration: Hashable {
    var taskName: String?
    var taskIcon: UIImage?

    var taskValueText: String?
    var taskValueIcon: String?

    var tintColor: UIColor?
}

extension TaskDetailItemConfiguration {
    init(careTask: SproutCareTaskMO) {
        let taskName = careTask.careInformation?.type?.capitalized ?? "Unknown Task"
        let taskIcon = careTask.careInformation?.iconImage
        let taskSchedule = careTask.schedule?.description ?? "No schedule"
        let taskScheduleIcon = careTask.hasSchedule ? "bell.fill" : "bell.slash"
        let tintColor = careTask.careInformation?.tintColor

        self.init(taskName: taskName, taskIcon: taskIcon, taskValueText: taskSchedule, taskValueIcon: taskScheduleIcon, tintColor: tintColor)
    }
}
