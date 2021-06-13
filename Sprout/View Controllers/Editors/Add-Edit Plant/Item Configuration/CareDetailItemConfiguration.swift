//
//  CareDetailItemConfiguration.swift
//  Sprout
//
//  Created by Ryan Thally on 6/11/21.
//

import UIKit

struct CareDetailItemConfiguration: Hashable {
    let image: UIImage?
    let title: String?
    let subtitle: String?
    let handler: (() -> Void)?

    func hash(into hasher: inout Hasher) {
        hasher.combine(image)
        hasher.combine(title)
        hasher.combine(subtitle)
    }

    static func == (lhs: CareDetailItemConfiguration, rhs: CareDetailItemConfiguration) -> Bool {
        lhs.image == rhs.image
            && lhs.title == rhs.title
            && lhs.subtitle == rhs.subtitle
    }
}

extension CareDetailItemConfiguration {
    init(careTask: SproutCareTaskMO, handler: (() -> Void)?) {
        let scheduleFormatter = Utility.careScheduleFormatter

        var subtitleText: String?
        if careTask.isTemplate {
            subtitleText = "Configure"
        } else if let schedule = careTask.schedule {
            subtitleText = scheduleFormatter.string(from: schedule)
        }

        self.init(image: careTask.taskTypeProperties?.icon, title: careTask.taskTypeProperties?.displayName, subtitle: subtitleText, handler: handler)
    }
}
