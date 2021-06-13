//
//  DayOfMonthPickerConfiguration.swift
//  Sprout
//
//  Created by Ryan Thally on 6/12/21.
//

import Foundation

struct DayOfMonthPickerConfiguration: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(currentSelection)
    }

    static func == (lhs: DayOfMonthPickerConfiguration, rhs: DayOfMonthPickerConfiguration) -> Bool {
        lhs.currentSelection == rhs.currentSelection
    }

    var currentSelection: Set<Int>
    var handler: ((DayOfMonthPicker) -> Void)?
}
