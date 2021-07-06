//
//  CareDetailItemConfiguration.swift
//  Sprout
//
//  Created by Ryan Thally on 6/11/21.
//

import UIKit
import SproutKit

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
    init(careTask task: SproutCareTaskMO, handler: (() -> Void)?) {
        let taskIcon = task.careInformation?.iconImage ?? UIImage(systemName: "list.bullet.rectangle")

        let scheduleFormatter = Utility.careScheduleFormatter
        var subtitleText: String?
        if let schedule = task.schedule {
            subtitleText = scheduleFormatter.string(from: schedule)
        } else {
            subtitleText = "Any Time"
        }

        self.init(image: taskIcon, title: task.careInformation?.type?.capitalized, subtitle: subtitleText, handler: handler)
    }

    init(taskType: SproutCareType, handler: (() -> Void)? ) {
        let iconName = taskType.icon ?? "list.bullet.rectangle"
        let taskIcon = UIImage(named: iconName) ?? UIImage(systemName: iconName)

        self.init(image: taskIcon, title: taskType.rawValue.capitalized, subtitle: "Configure", handler: handler)
    }

    init(careInformation careInfo: SproutCareInformationMO, handler: (() -> Void)? ) {
        let iconName = careInfo.icon ?? ""
        let taskIcon = UIImage(named: iconName) ?? UIImage(systemName: iconName) ?? UIImage(systemName: "list.bullet.rectangle")

        self.init(image: taskIcon, title: careInfo.type?.capitalized, subtitle: "Configure", handler: handler)
    }
}
