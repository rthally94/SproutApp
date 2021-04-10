//
//  GHTaskInterval+Extensions.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/7/21.
//

import Foundation

extension GHTaskInterval {
    func frequency() -> GHTaskIntervalType {
        GHTaskIntervalType(rawValue: Int(type)) ?? .none
    }
    
    func frequencyText() -> String {
        switch frequency() {
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
    
    func valueText() -> String? {
        switch frequency() {
        case .none:
            return "no interval"
        case .daily:
            if let value = values?.first {
                return "every \(value) days"
            } else {
                return nil
            }
        case .weekly:
            guard let values = values else { return nil }
            let weekdayStrings: [String] = values.sorted().compactMap {
                let weekdayIndex = $0 - 1
                if weekdayIndex >= Calendar.current.shortWeekdaySymbols.startIndex && weekdayIndex < Calendar.current.shortWeekdaySymbols.endIndex {
                    return Calendar.current.shortWeekdaySymbols[weekdayIndex]
                } else {
                    return nil
                }
            }
            
            return weekdayStrings.joined(separator: ", ")
            
        case .monthly:
            guard let values = values else { return nil }
            let dayStrings: [String] = values.sorted().compactMap {
                let number = NSNumber(value: $0)
                return TaskInterval.ordinalNumberFormatter.string(from: number)
            }
            
            return dayStrings.joined(separator: ", ")
        }
    }
    
    func intervalText() -> String {
        let valueString = valueText()?.sentenceCase()
        let frequencyString = frequencyText().sentenceCase()
        
        switch frequency() {
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
