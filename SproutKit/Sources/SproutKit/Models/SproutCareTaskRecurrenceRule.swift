//
//  SproutCareTaskRecurrenceRule.swift
//  Sprout
//
//  Created by Ryan Thally on 6/17/21.
//

import Foundation

enum SproutCareTaskRecurrenceRule {
    case daily(Int)
    case weekly(Int, Set<Int>? = nil)
    case monthly(Int, Set<Int>? = nil)

    func nextDate(after targetDate: Date) -> Date? {
        switch self {
        case let .daily(interval):
            return Calendar.current.date(byAdding: .day, value: interval, to: targetDate)
        default:
            let upcomingDates = dateComponents?.compactMap({ dateComponents in
                Calendar.current.nextDate(after: targetDate, matching: dateComponents, matchingPolicy: .nextTime)
            }).sorted()
            return upcomingDates?.first
        }
    }

    var dateComponents: Set<DateComponents>? {
        switch self {
        case .daily(let interval):
            return [DateComponents(day: interval)]
        case .weekly(let interval, let weekdays?) where interval == 1:
            return Set<DateComponents>( weekdays.map { DateComponents(weekday: $0) } )
        case .monthly(let interval, let days?) where interval == 1:
            return Set<DateComponents>( days.map { DateComponents(day: $0) } )
        default:
            return nil
        }
    }
}

extension SproutCareTaskRecurrenceRule: Equatable { }
