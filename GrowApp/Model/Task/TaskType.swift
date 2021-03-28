//
//  TaskType.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/5/21.
//

import UIKit

enum TaskType: String, Hashable, CaseIterable, CustomStringConvertible {
    case watering
    case pruning
    case fertilizing
    case potting

    var description: String {
        return self.rawValue.capitalized
    }

    var icon: Icon? {
        switch self {
        case .watering: return .symbol(name: "drop.fill", tintColor: UIColor(named: "ghBlue"))
        case .pruning: return .symbol(name: "scissors", tintColor: UIColor(named: "ghGreen"))
        case .fertilizing: return .symbol(name: "leaf.fill", tintColor: UIColor(named: "ghOrange"))
        case .potting: return .symbol(name: "rectangle.roundedbottom.fill", tintColor: UIColor(named: "ghRed"))
        }
    }

    var accentColor: UIColor? {
        if let icon = self.icon, case let .symbol(_, color) = icon {
            return color
        } else {
            return nil
        }
    }
}
