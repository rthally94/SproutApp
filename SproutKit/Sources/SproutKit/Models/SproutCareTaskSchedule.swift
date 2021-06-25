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
        self.init(startDate: startDate, dueDate: dueDate, recurrenceRule: nil)
    }

    init?(startDate: Date, recurrenceRule: SproutCareTaskRecurrenceRule) {
        guard let nextPossibleDate = recurrenceRule.nextDate(after: startDate) else { return nil }
        self.init(startDate: startDate, dueDate: nextPossibleDate, recurrenceRule: recurrenceRule)
    }

    init?(startDate: Date, dueDate: Date, recurrenceRule: SproutCareTaskRecurrenceRule?) {
        if recurrenceRule != nil {
            guard dueDate == recurrenceRule?.nextDate(after: startDate) else { return nil }
        } else {
            guard dueDate > startDate else { return nil }
        }

        self.startDate = startDate
        self.dueDate = dueDate
        self.recurrenceRule = recurrenceRule
    }

    var description: String {
        let formatter = Utility.careScheduleFormatter
        return formatter.string(from: self)
    }
}

extension SproutCareTaskSchedule: Equatable { }
