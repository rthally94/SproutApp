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
        let iconName = careTask.careInformation?.icon ?? ""
        let taskIcon = UIImage(named: iconName) ?? UIImage(systemName: iconName)
        let taskSchedule = Utility.careScheduleFormatter.string(for: careTask.schedule) ?? "No schedule"
        let taskScheduleIcon = careTask.hasSchedule ? "bell.fill" : "bell.slash"
        let tintColor = careTask.careInformation?.tintColor

        self.init(taskName: taskName, taskIcon: taskIcon, taskValueText: taskSchedule, taskValueIcon: taskScheduleIcon, tintColor: tintColor)
    }
}
