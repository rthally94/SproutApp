//
//  UpNextSection.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/6/21.
//

import Foundation

enum UpNextSection: Hashable {
    case scheduled(Date)
    case unscheduled

    var headerTitle: String? {
        switch self {
        case let .scheduled(date):
            return Utility.relativeDateFormatter.string(from: date)
        case .unscheduled:
            return "Any Time"
        }
    }
}
