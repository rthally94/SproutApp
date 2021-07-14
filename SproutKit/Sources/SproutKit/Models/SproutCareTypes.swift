//
//  SproutCareTypes.swift
//  Sprout
//
//  Created by Ryan Thally on 6/17/21.
//

import UIKit

public enum SproutCareType: String, Hashable, CaseIterable {
    case watering
    case fertilizing
    case pruning

    public var icon: String? {
        switch self {
        case .watering:
            return "drop.fill"
        case .fertilizing:
            return "aqi.medium"
        case .pruning:
            return "scissors"
        }
    }

    public var tintColorHex: String? {
        switch self {
        case .watering:
            return UIColor.systemBlue.hexString()
        case .fertilizing:
            return UIColor.systemGreen.hexString()
        case .pruning:
            return UIColor.systemOrange.hexString()
        }
    }
}
