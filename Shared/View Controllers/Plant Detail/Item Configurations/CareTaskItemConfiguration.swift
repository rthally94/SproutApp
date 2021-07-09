//
//  CareTaskItemConfiguration.swift
//  Sprout
//
//  Created by Ryan Thally on 7/9/21.
//

import UIKit
import SproutKit

struct CareTaskItemConfiguration: Hashable {
    let icon: UIImage?
    let taskName: String?
    let taskSchedule: String?
}

extension CareTaskItemConfiguration {
    init(task: SproutCareTaskMO) {
        icon = task.careInformation?.iconImage
        taskName = task.careInformation?.type?.capitalized
        taskSchedule = task.schedule?.description
    }
}
