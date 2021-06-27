//
//  TaskEditorItem.swift
//  Sprout
//
//  Created by Ryan Thally on 6/10/21.
//

import Foundation

enum TaskEditorItem: Hashable {
    case detailHeader(TaskDetailItemConfiguration)
    case repeatsIntervalRow(ToggleItemConfiguration)
    case remindersToggle(ToggleItemConfiguration)
    case dayOfWeekPicker(DayOfWeekPickerConfiguration)
    case dayOfMonthPicker(DayOfMonthPickerConfiguration)
}
