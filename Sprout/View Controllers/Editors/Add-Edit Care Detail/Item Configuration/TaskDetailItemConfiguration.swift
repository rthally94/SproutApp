//
//  TaskDetailHeaderItemConfiguration.swift
//  Sprout
//
//  Created by Ryan Thally on 6/12/21.
//

import UIKit

struct TaskDetailItemConfiguration: Hashable {
    var taskName: String?
    var taskIcon: UIImage?

    var taskValueText: String?
    var taskValueIcon: String?

    var tintColor: UIColor?
}

extension TaskDetailItemConfiguration {
    init(careTask: SproutCareTaskMO) {
        let taskSchedule = Utility.careScheduleFormatter.string(for: careTask.schedule) ?? "No schedule"
        let taskIcon = careTask.hasSchedule ? "bell.fill" : "bell.slash"

        self.init(taskName: careTask.taskTypeProperties?.displayName, taskIcon: careTask.taskTypeProperties?.icon, taskValueText: taskSchedule, taskValueIcon: taskIcon, tintColor: careTask.taskTypeProperties?.tintColor)
    }
}
