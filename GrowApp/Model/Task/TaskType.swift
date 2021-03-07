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
        case .watering: return .symbol(name: "drop.fill", foregroundColor: nil, backgroundColor: .systemBlue)
        case .pruning: return .symbol(name: "scissors", foregroundColor: nil, backgroundColor: .systemGreen)
        case .fertilizing: return .symbol(name: "leaf.fill", foregroundColor: nil, backgroundColor: .systemOrange)
        case .potting: return .symbol(name: "rectangle.roundedbottom.fill", foregroundColor: nil, backgroundColor: .systemRed)
        }
    }

    var accentColor: UIColor? {
        if let icon = self.icon, case let .symbol(_, _, color) = icon {
            return color
        } else {
            return nil
        }
    }
}
