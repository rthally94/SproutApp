//
//  SproutCareTypes.swift
//  Sprout
//
//  Created by Ryan Thally on 6/17/21.
//

import UIKit

enum SproutCareType: String, Hashable, CaseIterable {
    case watering

    var icon: String? {
        switch self {
        case .watering:
            return UIImage.WateringIconName
        }
    }
}
