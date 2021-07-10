//
//  CareTaskItemConfiguration.swift
//  Sprout
//
//  Created by Ryan Thally on 7/9/21.
//

import UIKit
import SproutKit

struct CareTaskItemConfiguration {
    let icon: UIImage?
    let taskName: String?
    let taskSchedule: String?
    let status: SproutMarkStatus?
    let handler: (() -> Void)?

    var isDue: Bool {
        status == .due
    }
}

extension CareTaskItemConfiguration: Hashable {
    static func == (lhs: CareTaskItemConfiguration, rhs: CareTaskItemConfiguration) -> Bool {
        lhs.icon == rhs.icon
            && lhs.taskName == rhs.taskName
            && lhs.taskSchedule == rhs.taskSchedule
            && lhs.status == rhs.status
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(icon)
        hasher.combine(taskName)
        hasher.combine(taskSchedule)
        hasher.combine(status)
    }
}

extension CareTaskItemConfiguration {
    init(task: SproutCareTaskMO, handler: @escaping () -> Void) {
        icon = task.careInformation?.iconImage
        taskName = task.careInformation?.type?.capitalized
        taskSchedule = task.schedule?.description
        status = task.markStatus
        self.handler = handler
    }
}
