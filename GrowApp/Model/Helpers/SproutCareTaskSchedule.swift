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
        guard let nextDate = recurrenceRule.nextDate(after: startDate) else { return nil }
        self.init(startDate: startDate, dueDate: nextDate, recurrenceRule: recurrenceRule)
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

enum SproutCareTaskRecurrenceRule {
    case daily(Int)
    case weekly(Int, Set<Int>? = nil)
    case monthly(Int, Set<Int>? = nil)

    func nextDate(after targetDate: Date) -> Date? {
        let upcomingDates = dateComponents?.compactMap({ dateComponents in
            Calendar.current.nextDate(after: targetDate, matching: dateComponents, matchingPolicy: .nextTime)
        }).sorted()
        return upcomingDates?.first
    }

    var dateComponents: Set<DateComponents>? {
        switch self {
        case .daily(let interval):
            return [DateComponents(day: interval)]
        case .weekly(let interval, let weekdays) where interval == 1:
            return Set<DateComponents>( weekdays?.map { DateComponents(weekday: $0) } ?? [] )
        case .monthly(let interval, let days) where interval == 1:
            return Set<DateComponents>( days?.map { DateComponents(day: $0) } ?? [] )
        default:
            return nil
        }
    }

    var daysOfWeek: Set<Int>? {
        switch self {
        case .weekly(_, let days):
            return days
        default:
            return nil
        }
    }

    var daysOfMonth: Set<Int>? {
        switch self {
        case .monthly(_, let days):
            return days
        default:
            return nil
        }
    }

    var frequency: String {
        switch self {
        case .daily:
            return "daily"
        case .weekly:
            return "weekly"
        case .monthly:
            return "monthly"
        }
    }

    var interval: Int {
        switch self {
        case .daily(let interval):
            return interval
        case .weekly(let interval, _):
            return interval
        case .monthly(let interval, _):
            return interval
        }
    }
}
