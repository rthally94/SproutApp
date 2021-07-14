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
    let tintColor: UIColor?
    let handler: (() -> Void)?

    func hash(into hasher: inout Hasher) {
        hasher.combine(image)
        hasher.combine(title)
        hasher.combine(subtitle)
        hasher.combine(tintColor)
    }

    static func == (lhs: CareDetailItemConfiguration, rhs: CareDetailItemConfiguration) -> Bool {
        lhs.image == rhs.image
            && lhs.title == rhs.title
            && lhs.subtitle == rhs.subtitle
            && lhs.tintColor == rhs.tintColor
    }
}

extension CareDetailItemConfiguration {
    init(careTask task: SproutCareTaskMO, handler: (() -> Void)?) {
        let taskIcon = task.careInformation?.iconImage ?? UIImage(systemName: "heart.text.square.fill")

        let scheduleFormatter = Utility.careScheduleFormatter
        var subtitleText: String?
        if let schedule = task.schedule {
            subtitleText = scheduleFormatter.string(from: schedule)
        } else {
            subtitleText = "Any Time"
        }

        var tintColor: UIColor?
        if let hex = task.careInformation?.careType?.tintColorHex {
            tintColor = UIColor(hex: hex)
        }

        self.init(image: taskIcon, title: task.careInformation?.type?.capitalized, subtitle: subtitleText, tintColor: tintColor, handler: handler)
    }

    init(taskType: SproutCareType, handler: (() -> Void)? ) {
        let iconName = taskType.icon ?? "heart.text.square.fill"
        let taskIcon = UIImage(named: iconName) ?? UIImage(systemName: iconName)

        let taskName = taskType.rawValue.capitalized
        let subtitleText = "Configure"
        var tintColor: UIColor?
        if let hex = taskType.tintColorHex {
            tintColor = UIColor(hex: hex)
        }

        self.init(image: taskIcon, title: taskName, subtitle: subtitleText, tintColor: tintColor, handler: handler)
    }

    init(careInformation careInfo: SproutCareInformationMO, handler: (() -> Void)? ) {
        let taskIcon = careInfo.iconImage
        let taskName = careInfo.type?.capitalized
        let scheduleText = careInfo.latestTask?.schedule?.description ?? "Any Time"
        var tintColor: UIColor?
        if let hex = careInfo.careType?.tintColorHex {
            tintColor = UIColor(hex: hex)
        }

        self.init(image: taskIcon, title: taskName, subtitle: scheduleText, tintColor: tintColor, handler: handler)
    }
}
