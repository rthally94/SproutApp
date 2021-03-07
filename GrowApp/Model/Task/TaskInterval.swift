//
//  TaskInterval.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/5/21.
//

import Foundation

enum TaskInterval: CustomStringConvertible, Hashable {
    static let listFormatter: ListFormatter = {
        let formatter = ListFormatter()
        return formatter
    }()

    static let ordinalNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter
    }()

    case none
    case daily(Int)
    case weekly(Set<Int>)
    case monthly(Set<Int>)

    var description: String {
        switch self {
            case .none:
                return "Never"
            case .daily(let interval):
                if interval > 1 {
                    return "Every \(interval) Days"
                } else {
                    return "Every Day"
                }
            case .weekly(let weekdays):
                let weekdayStrings: [String] = weekdays.sorted().compactMap {
                    let weekdayIndex = $0 - 1
                    if weekdayIndex >= Calendar.current.shortWeekdaySymbols.startIndex && weekdayIndex < Calendar.current.shortWeekdaySymbols.endIndex {
                        return Calendar.current.shortWeekdaySymbols[weekdayIndex]
                    } else {
                        return nil
                    }
                }

                if let weekdayList = TaskInterval.listFormatter.string(from: weekdayStrings) {
                    return "Every Week on \(weekdayList)"
                } else {
                    return "Every Week"
                }
            case .monthly(let days):
                let dayStrings: [String] = days.sorted().compactMap {
                    let number = NSNumber(value: $0)
                    return TaskInterval.ordinalNumberFormatter.string(from: number)
                }

                if let dayList = TaskInterval.listFormatter.string(from: dayStrings) {
                    return "Every Month on the \(dayList)"
                } else {
                    return "Ever Month"
                }
        }
    }
}