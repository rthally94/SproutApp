//
//  GHTaskInterval+Extensions.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/7/21.
//

import Foundation

extension GHTaskInterval {
    var wrappedFrequency: GHTaskIntervalType {
        guard let frequency = repeatsFrequency else { return .never }
        return GHTaskIntervalType(rawValue: frequency) ?? .never
    }

    var componentsArray: [Int] {
        return repeatsValues ?? []
    }
}

extension GHTaskInterval {
    func frequencyText() -> String {
        switch wrappedFrequency {
        case .never:
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
        switch wrappedFrequency {
        case .never:
            return "no interval"
        case .daily:
            if let value = componentsArray.first {
                return "every \(value) days"
            } else {
                return nil
            }
        case .weekly:
            guard !componentsArray.isEmpty else { return nil }
            let weekdayStrings: [String] = componentsArray.compactMap {
                let weekdayIndex = $0 - 1
                if weekdayIndex >= Calendar.current.shortWeekdaySymbols.startIndex && weekdayIndex < Calendar.current.shortWeekdaySymbols.endIndex {
                    return Calendar.current.shortWeekdaySymbols[weekdayIndex]
                } else {
                    return nil
                }
            }
            
            return weekdayStrings.joined(separator: ", ")
            
        case .monthly:
            guard !componentsArray.isEmpty else { return nil }
            let dayStrings: [String] = componentsArray.compactMap {
                let number = NSNumber(value: $0)
                return TaskInterval.ordinalNumberFormatter.string(from: number)
            }
            
            return dayStrings.joined(separator: ", ")
        }
    }
    
    func intervalText() -> String {
        let valueString = valueText()?.sentenceCase()
        let frequencyString = frequencyText().sentenceCase()
        
        switch wrappedFrequency {
        case .never:
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
