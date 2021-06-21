//
//  SproutCareTaskSchedule.swift
//  GrowApp
//
//  Created by Ryan Thally on 6/3/21.
//

import Foundation

struct SproutCareTaskSchedule {
    let startDate: Date
    let dueDate: Date

    let recurrenceRule: SproutCareTaskRecurrenceRule?

    init?(startDate: Date, dueDate: Date) {
        guard startDate < dueDate else { return nil }
        self.init(startDate: startDate, dueDate: dueDate, recurrenceRule: nil)
    }

    init?(startDate: Date, recurrenceRule: SproutCareTaskRecurrenceRule) {
        guard let nextPossibleDate = recurrenceRule.nextDate(after: Date()) else { return nil }

        self.init(startDate: startDate, dueDate: nextPossibleDate, recurrenceRule: recurrenceRule)
    }

    init(startDate: Date, dueDate: Date, recurrenceRule: SproutCareTaskRecurrenceRule?) {
        self.startDate = startDate
        self.dueDate = dueDate
        self.recurrenceRule = recurrenceRule
    }

    var description: String {
        let formatter = Utility.careScheduleFormatter
        return formatter.string(from: self)
    }
}
