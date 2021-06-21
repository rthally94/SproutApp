//
//  SproutCareInformationMO+SwiftProperties.swift
//  Sprout
//
//  Created by Ryan Thally on 6/21/21.
//

import SproutKit
import UIKit

extension SproutCareInformationMO {
    var tintColor: UIColor? {
        get {
            guard let hex = tintColor_hex else { return nil }
            return UIColor(hex: hex)
        }
        set {
            tintColor_hex = newValue?.hexString()
        }
    }

    var iconImage: UIImage? {
        guard let iconName = icon else { return UIImage.WateringIcon }
        return UIImage(named: iconName) ?? UIImage(named: iconName) ?? UIImage.WateringIcon
    }

    var allTasks: [SproutCareTaskMO] {
        let taskSet = tasks as? Set<SproutCareTaskMO>
        return taskSet?.sorted(by: { lhs, rhs in
            lhs.creationDate > rhs.creationDate
        }) ?? []
    }

    var latestTask: SproutCareTaskMO? {
        allTasks.first
    }
}
