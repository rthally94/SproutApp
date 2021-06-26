//
//  File.swift
//  
//
//  Created by Ryan Thally on 6/26/21.
//

import UIKit

public extension SproutCareInformationMO {
    var careType: SproutCareType? {
        get {
            guard let type = type else { return nil }
            return SproutCareType(rawValue: type)
        }

        set {
            type = newValue?.rawValue
        }
    }

    var tintColor: UIColor? {
        if let hex = careType?.tintColorHex {
            return UIColor(hex: hex)
        }

        return nil
    }

    var iconImage: UIImage? {
        guard let iconName = careType?.icon else { return nil }
        if let image = UIImage(named: iconName) {
            return image
        } else if let image = UIImage(systemName: iconName) {
            return image
        } else {
            return nil
        }
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
