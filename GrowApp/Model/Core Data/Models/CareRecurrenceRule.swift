//
//  CareInfoInterval.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/30/21.
//

import CoreData

public class CareRecurrenceRule: NSManagedObject {
    static let RepeatsNeverFrequency = "never"
    static let RepeatsDailyFrequency = "daily"
    static let RepeatsWeeklyFrequency = "weekly"
    static let RepeatsMonthlyFrequency = "monthly"

    private static func defaultRecurrenceRule(context: NSManagedObjectContext) -> CareRecurrenceRule {
        let recurrenceRule = CareRecurrenceRule(context: context)
        recurrenceRule.id = UUID()
        recurrenceRule.creationDate = Date()
        recurrenceRule.frequency = .never

        assert(recurrenceRule.isValid())
        return recurrenceRule
    }

    static func daily(interval: Int, context: NSManagedObjectContext) -> CareRecurrenceRule {
        let recurrenceRule = defaultRecurrenceRule(context: context)
        recurrenceRule.frequency = .daily
        recurrenceRule.interval = interval
        recurrenceRule.firstDayOfTheWeek = Calendar.current.firstWeekday

        assert(recurrenceRule.isValid())
        return recurrenceRule
    }

    static func weekly(interval: Int, context: NSManagedObjectContext) -> CareRecurrenceRule {
        let recurrenceRule = defaultRecurrenceRule(context: context)
        recurrenceRule.frequency = .weekly
        recurrenceRule.interval = interval
        recurrenceRule.firstDayOfTheWeek = Calendar.current.firstWeekday

        assert(recurrenceRule.isValid())
        return recurrenceRule
    }

    static func weekly(daysOfTheWeek: Set<Int>, context: NSManagedObjectContext) -> CareRecurrenceRule {
        let recurrenceRule = defaultRecurrenceRule(context: context)
        recurrenceRule.frequency = .weekly
        recurrenceRule.interval = 1
        recurrenceRule.daysOfTheWeek = daysOfTheWeek
        recurrenceRule.firstDayOfTheWeek = Calendar.current.firstWeekday

        assert(recurrenceRule.isValid())
        return recurrenceRule
    }

    static func monthly(interval: Int, context: NSManagedObjectContext) -> CareRecurrenceRule {
        let recurrenceRule = defaultRecurrenceRule(context: context)
        recurrenceRule.frequency = .monthly
        recurrenceRule.interval = interval
        recurrenceRule.firstDayOfTheWeek = Calendar.current.firstWeekday

        assert(recurrenceRule.isValid())
        return recurrenceRule
    }

    static func monthly(daysOfTheMonth: Set<Int>, context: NSManagedObjectContext) -> CareRecurrenceRule {
        let recurrenceRule = defaultRecurrenceRule(context: context)
        recurrenceRule.frequency = .monthly
        recurrenceRule.interval = 1
        recurrenceRule.daysOfTheMonth = daysOfTheMonth
        recurrenceRule.firstDayOfTheWeek = Calendar.current.firstWeekday

        assert(recurrenceRule.isValid())
        return recurrenceRule
    }

    func nextDate(after testDate: Date) -> Date? {
        var returnDate: Date? = nil

        switch frequency {
        case .daily:
            guard interval > 0 else { break }
            if let newDate = Calendar.current.date(byAdding: .day, value: interval, to: testDate, wrappingComponents: true) {
                returnDate = Calendar.current.startOfDay(for: newDate)
            }
            
        case .weekly:
            let currentWeekday = Calendar.current.component(.weekday, from: testDate)
            let weekdayComponents = daysOfTheWeek?.sorted()
            guard let nextWeekday = weekdayComponents?.first(where: { $0 > currentWeekday }) ?? weekdayComponents?.first else { break }
            let nextDateComponents = DateComponents(weekday: nextWeekday)
            guard let nextDate = Calendar.current.nextDate(after: testDate, matching: nextDateComponents, matchingPolicy: .nextTime) else { break }
            returnDate = nextDate
            
        case .monthly:
            let currentDay = Calendar.current.component(.day, from: testDate)
            let dayComponents = daysOfTheMonth?.sorted()
            guard let nextDay = dayComponents?.first(where: { $0 > currentDay }) ?? dayComponents?.first else { break }
            let nextDayComponents = DateComponents(day: nextDay)
            guard let nextDate = Calendar.current.nextDate(after: testDate, matching: nextDayComponents, matchingPolicy: .nextTime) else { break }
            returnDate = nextDate
            
        default:
            break
        }
        
        return returnDate
    }
}

extension CareRecurrenceRule: SproutIntervalProtocol {
    var frequency: SproutRecurrenceFrequency {
        get {
            guard let recurrenceFrequency = recurrenceFrequency, let wrappedRecurrenceFrequency = SproutRecurrenceFrequency(rawValue: recurrenceFrequency) else { fatalError("Unknown value read for recurrence frequency: \(String(describing: self.recurrenceFrequency))") }
            return wrappedRecurrenceFrequency
        }

        set {
            recurrenceFrequency = newValue.rawValue
        }
    }
    
    var interval: Int {
        get { return Int(recurrenceInterval) }
        set { recurrenceInterval = Int16(newValue) }
    }
    
    var firstDayOfTheWeek: Int {
        get { return Int(recurrenceFirstDayOfWeek) }
        set { recurrenceFirstDayOfWeek = Int16(newValue) }
    }
    
    var daysOfTheWeek: Set<Int>? {
        get { recurrenceDaysOfWeek }
        set { recurrenceDaysOfWeek = newValue }
    }
    
    var daysOfTheMonth: Set<Int>? {
        get { recurrenceDaysOfMonth }
        set { recurrenceDaysOfMonth = newValue }
    }
}

extension CareRecurrenceRule {
    func frequencyText() -> String {
        switch frequency {
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
        switch frequency {
        case .never:
            return "no interval"
        case .daily:
            let formatter = Utility.dateComponentsFormatter
            let components = DateComponents(day: interval)
            return formatter.string(from: components)
        case .weekly:
            guard let weekdayComponents = daysOfTheWeek else { return nil }
            let weekdayStrings: [String] = weekdayComponents.sorted().compactMap {
                let weekdayIndex = $0 - 1
                if weekdayIndex >= Calendar.current.shortWeekdaySymbols.startIndex && weekdayIndex < Calendar.current.shortWeekdaySymbols.endIndex {
                    return Calendar.current.shortWeekdaySymbols[weekdayIndex]
                } else {
                    return nil
                }
            }
            
            return weekdayStrings.joined(separator: ", ")
            
        case .monthly:
            guard let dayComponents = daysOfTheMonth else { return nil }
            let dayStrings: [String] = dayComponents.sorted().compactMap {
                let number = NSNumber(value: $0)
                return Utility.ordinalNumberFormatter.string(from: number)
            }
            
            return dayStrings.joined(separator: ", ")
        }
    }
    
    func intervalText() -> String {
        let valueString = valueText()?.sentenceCase()
        let frequencyString = frequencyText().sentenceCase()
        
        switch frequency {
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
