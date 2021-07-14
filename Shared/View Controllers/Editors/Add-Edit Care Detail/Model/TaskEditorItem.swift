//
//  TaskEditorItem.swift
//  Sprout
//
//  Created by Ryan Thally on 6/10/21.
//

import Foundation
import SproutKit

enum TaskEditorItem {
    case taskHeader
    case remindersSwitch
    case recurrenceFrequencyChoice(RepeatFrequencyChoices)
    case dayOfWeekPicker
    case dayOfMonthPicker
}

extension TaskEditorItem: Hashable {
    static func ==(lhs: TaskEditorItem, rhs: TaskEditorItem) -> Bool {
        switch (lhs, rhs) {
        case let (.recurrenceFrequencyChoice(lhsChoice), .recurrenceFrequencyChoice(rhsChoice)):
            return lhsChoice == rhsChoice
        case (.taskHeader, .taskHeader),
             (.remindersSwitch, .remindersSwitch),
             (.dayOfWeekPicker, .dayOfWeekPicker),
             (.dayOfMonthPicker, .dayOfMonthPicker):
            return true
        default: return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .taskHeader:
            hasher.combine(0)
        case .remindersSwitch:
            hasher.combine(1)
        case let .recurrenceFrequencyChoice(choice):
            hasher.combine(2)
            hasher.combine(choice)
        case .dayOfWeekPicker:
            hasher.combine(3)
        case .dayOfMonthPicker:
            hasher.combine(4)
        }
    }
}
