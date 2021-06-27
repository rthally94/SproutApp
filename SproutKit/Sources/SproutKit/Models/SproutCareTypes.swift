//
//  SproutCareTypes.swift
//  Sprout
//
//  Created by Ryan Thally on 6/17/21.
//

import UIKit

public enum SproutCareType: String, Hashable, CaseIterable {
    case watering

    public var icon: String? {
        switch self {
        case .watering:
            return "drop.fill"
        }
    }

    public var tintColorHex: String? {
        switch self {
        case .watering:
            return UIColor.systemBlue.hexString()
        }
    }
}
