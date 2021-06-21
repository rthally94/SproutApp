//
//  SproutCareType+Properties.swift
//  Sprout
//
//  Created by Ryan Thally on 6/21/21.
//

import SproutKit
import UIKit

extension SproutCareType {
    var icon: String? {
        switch self {
        case .watering:
            return UIImage.WateringIconName
        }
    }
}
