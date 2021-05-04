//
//  GHTaskInterval.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/30/21.
//

import CoreData

public class GHTaskInterval: NSManagedObject {
    static let RepeatsNeverFrequency = "never"
    static let RepeatsDailyFrequency = "daily"
    static let RepeatsWeeklyFrequency = "weekly"
    static let RepeatsMonthlyFrequency = "monthly"

    func nextDate(after testDate: Date) -> Date {
        var returnDate = Date()

        let interval = (wrappedFrequency, componentsArray)
        switch interval {
        case (.daily, let components):
            guard let value = components.first else { break }
            if let newDate = Calendar.current.date(byAdding: .day, value: value, to: testDate, wrappingComponents: true) {
                returnDate = newDate
            }

        case (.weekly, let components):
            let currentWeekday = Calendar.current.component(.weekday, from: testDate)
            guard let nextWeekday = components.first(where: { $0 > currentWeekday }) ?? components.first else { break }
            let nextDateComponents = DateComponents(weekday: nextWeekday)
            guard let nextDate = Calendar.current.nextDate(after: testDate, matching: nextDateComponents, matchingPolicy: .nextTime) else { break }
            returnDate = nextDate

        case (.monthly, let components):
            let currentDay = Calendar.current.component(.day, from: testDate)
            guard let nextDay = components.first(where: { $0 > currentDay }) ?? components.first else { break }
            let nextDayComponents = DateComponents(day: nextDay)
            guard let nextDate = Calendar.current.nextDate(after: testDate, matching: nextDayComponents, matchingPolicy: .nextTime) else { break }
            returnDate = nextDate

        default:
            break
        }

        return returnDate
    }

    public override func awakeFromFetch() {
        super.awakeFromFetch()

        let previousCareDate: Date
        if let lastLogDate = task?.lastLogDate, Calendar.current.isDateInToday(lastLogDate) {
            // Last Log is Today -> Next is after today
            previousCareDate = lastLogDate
        } else {
            let today = Calendar.current.startOfDay(for: Date())
            previousCareDate = today.addingTimeInterval(-1 * 24 * 60 * 60)
        }

        let nextCareDate = nextDate(after: previousCareDate)
        task?.nextCareDate = nextCareDate
    }
}

extension GHTaskInterval {
    var wrappedFrequency: GHTaskIntervalType {
        guard let frequency = repeatsFrequency else { return .never }
        return GHTaskIntervalType(rawValue: frequency) ?? .never
    }

    var componentsArray: [Int] {
        return repeatsValues?.sorted() ?? []
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
