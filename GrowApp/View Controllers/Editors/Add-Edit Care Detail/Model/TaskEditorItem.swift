//
//  TaskEditorItem.swift
//  Sprout
//
//  Created by Ryan Thally on 6/10/21.
//

import Foundation

struct TaskEditorItem: Identifiable, Hashable {
    enum Identifier: Hashable {
        case detailHeader
        case repeatsIntervalRow(RepeatFrequencyChoices)
        case remindersToggle
        case dayOfWeekPicker
        case dayOfMonthPicker

        var rawValue: String {
            return String(describing: self)
        }
    }

    var id: Identifier
    var isVisible: Bool
}
