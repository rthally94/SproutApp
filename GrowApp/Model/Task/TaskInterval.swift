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
    
    var frequency: String {
        switch self {
        case .none:
            return "never"
        case .daily:
            return "every day"
        case .weekly:
            return "every week"
        case .monthly:
            return "every month"
        }
    }
    
    var value: String? {
        switch self {
        case .none:
            return "no interval"
        case let .daily(interval):
            if interval > 1 {
                return "every \(interval) days"
            } else {
                return nil
            }
        case let .weekly(weekdays):
            let weekdayStrings: [String] = weekdays.sorted().compactMap {
                let weekdayIndex = $0 - 1
                if weekdayIndex >= Calendar.current.shortWeekdaySymbols.startIndex && weekdayIndex < Calendar.current.shortWeekdaySymbols.endIndex {
                    return Calendar.current.shortWeekdaySymbols[weekdayIndex]
                } else {
                    return nil
                }
            }
            
            return weekdayStrings.joined(separator: ", ")
            
        case let .monthly(days):
            let dayStrings: [String] = days.sorted().compactMap {
                let number = NSNumber(value: $0)
                return TaskInterval.ordinalNumberFormatter.string(from: number)
            }
            
            return dayStrings.joined(separator: ", ")
        }
    }
    
    var description: String {
        let valueString = value?.sentenceCase()
        let frequencyString = frequency.sentenceCase()
        
        switch self {
        case .none:
            return valueString ?? frequencyString
        case .daily:
            return valueString ?? frequencyString
        case .weekly:
            if let weekdayString = valueString {
                return "\(frequencyString) • \(weekdayString)"
            } else {
                return frequencyString
            }
        case .monthly:
            if let dayString = valueString {
                return "\(frequencyString) • \(dayString)"
            } else {
                return frequencyString
            }
        }
    }
}
