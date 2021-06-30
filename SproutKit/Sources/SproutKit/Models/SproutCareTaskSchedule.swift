//
//  SproutCareTaskSchedule.swift
//  GrowApp
//
//  Created by Ryan Thally on 6/3/21.
//

import Foundation

public struct SproutCareTaskSchedule {
    public let startDate: Date
    public let dueDate: Date

    public let recurrenceRule: SproutCareTaskRecurrenceRule?

    public init?(startDate: Date, dueDate: Date) {
        self.init(startDate: startDate, dueDate: dueDate, recurrenceRule: nil)
    }

    public init?(startDate: Date, recurrenceRule: SproutCareTaskRecurrenceRule) {
        guard let nextPossibleDate = recurrenceRule.nextDate(after: startDate) else { return nil }
        self.init(startDate: startDate, dueDate: nextPossibleDate, recurrenceRule: recurrenceRule)
    }

    init?(startDate: Date, dueDate: Date, recurrenceRule: SproutCareTaskRecurrenceRule?) {
        let midnightStartDate = Calendar.current.startOfDay(for: startDate)
        let midnightDueDate = Calendar.current.startOfDay(for: dueDate)

        if recurrenceRule != nil {
            guard midnightDueDate == recurrenceRule?.nextDate(after: midnightStartDate) else { return nil }
        } else {
            guard midnightDueDate > midnightStartDate else { return nil }
        }

        self.startDate = midnightStartDate
        self.dueDate = midnightDueDate
        self.recurrenceRule = recurrenceRule
    }

    public var description: String {
        let formatter = Utility.careScheduleFormatter
        switch recurrenceRule {
        case .daily:
            formatter.frequencyStyle = .none
            return "Every " + formatter.string(from: self)
        default:
            formatter.frequencyStyle = .short
            return formatter.string(from: self)
        }
    }
}

extension SproutCareTaskSchedule: Equatable { }
