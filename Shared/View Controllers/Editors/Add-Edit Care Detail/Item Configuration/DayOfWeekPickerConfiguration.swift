//
//  DayOfWeekPickerConfiguration.swift
//  Sprout
//
//  Created by Ryan Thally on 6/12/21.
//

import Foundation

struct DayOfWeekPickerConfiguration: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(currentSelection)
    }

    static func == (lhs: DayOfWeekPickerConfiguration, rhs: DayOfWeekPickerConfiguration) -> Bool {
        lhs.currentSelection == rhs.currentSelection
    }

    var currentSelection: Set<Int>
    var handler: ((DayOfWeekPicker) -> Void)?
}
