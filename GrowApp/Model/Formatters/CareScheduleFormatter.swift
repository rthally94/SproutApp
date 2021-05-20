//
//  SproutIntervalFormatter.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/11/21.
//

import Foundation

class CareScheduleFormatter: Formatter {
    private let dateFormatter = Utility.dateFormatter
    private let recurrenceRuleFormatter = CareRecurrenceRuleFormatter()

    enum Style {
        case none, short, full
    }

    var frequencyStyle: CareRecurrenceRuleFormatter.Style {
        get { recurrenceRuleFormatter.frequencyStyle }
        set { recurrenceRuleFormatter.frequencyStyle = newValue }
    }
    var valuesStyle: CareRecurrenceRuleFormatter.Style {
        get { recurrenceRuleFormatter.valuesStyle }
        set { recurrenceRuleFormatter.valuesStyle = newValue }
    }


    var dateStyle: Style = .none
    var formattingContext: Context = .dynamic {
        didSet {
            recurrenceRuleFormatter.formattingContext = formattingContext
        }
    }

    override func string(for obj: Any?) -> String? {
        guard let obj = obj as? CareSchedule else { return nil }
        return string(for: obj)
    }

    func string(for interval: CareSchedule) -> String {
        let frequencyText = recurrenceRuleFormatter.string(for: interval.recurrenceRule) ?? ""
        return frequencyText
    }
}

class CareRecurrenceRuleFormatter: Formatter {
    enum Style {
        case none, short, full
    }

    var frequencyStyle: Style = .none
    var valuesStyle: Style = .none
    var formattingContext: Context = .dynamic

    override func string(for obj: Any?) -> String? {
        guard let obj = obj as? CareRecurrenceRule else { return nil }
        return string(for: obj)
    }

    func string(for rule: CareRecurrenceRule) -> String {
        let frequencyText = frequencySymbol(for: rule.frequency, style: frequencyStyle, context: formattingContext)

        let valueText: String
        if rule.frequency == .weekly, let daysOfTheWeek = rule.daysOfTheWeek, !daysOfTheWeek.isEmpty {
            // weekday values
            valueText = daysOfTheWeekSymbol(for: daysOfTheWeek, style: valuesStyle, context: formattingContext)
        } else if rule.frequency == .weekly, let daysOfTheMonth = rule.daysOfTheMonth, !daysOfTheMonth.isEmpty {
            // day values
            valueText = daysOfTheMonthSymbol(for: daysOfTheMonth, style: valuesStyle, context: formattingContext)
        } else {
            // interval value
            valueText = intervalSymbol(for: rule.interval, frequency: rule.frequency, style: valuesStyle, context: formattingContext)
        }

        let ruleString: String

        switch formattingContext {
        case .standalone:
            if !frequencyText.isEmpty, !valueText.isEmpty {
                ruleString = frequencyText + " • " + valueText
            } else {
                ruleString = frequencyText + valueText
            }
        default:
            ruleString = "Not Implemented"
        }

        return ruleString
    }

    // MARK: - Frequency
    private func frequencySymbol(for frequency: SproutRecurrenceFrequency, style: Style, context: Context) -> String {
        let parameters = (style, context)
        switch parameters {
        case (.short, .standalone):
            return shortStandaloneFrequencySymbol(for: frequency)
        case (.full, .standalone):
            return regularStandaloneFrequencySymbol(for: frequency)
        case (.short, _):
            return shortFrequencySymbol(for: frequency)
        case (.full, _):
            return regularFrequencySymbol(for: frequency)
        default:
            return ""
        }
    }

    func regularFrequencySymbol(for frequency: SproutRecurrenceFrequency) -> String {
        switch frequency {
        case .daily:
            return "Every day"
        case .weekly:
            return "Every week"
        case .monthly:
            return "Every month"
        case .never:
            return "Not scheduled"
        }
    }

    func shortFrequencySymbol(for frequency: SproutRecurrenceFrequency) -> String {
        switch frequency {
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        case .never:
            return "Never"
        }
    }

    func regularStandaloneFrequencySymbol(for frequency: SproutRecurrenceFrequency) -> String {
        return regularFrequencySymbol(for: frequency).capitalized
    }

    func shortStandaloneFrequencySymbol(for frequency: SproutRecurrenceFrequency) -> String {
        return shortFrequencySymbol(for: frequency).capitalized
    }

    // MARK: - Interval
    private func intervalSymbol(for interval: Int, frequency: SproutRecurrenceFrequency, style: Style, context: Context) -> String {
        let parameters = (style, context)
        switch parameters {
        case (.short, .standalone):
            return shortStandaloneIntervalSymbol(for: interval, frequency: frequency)
        case (.full, .standalone):
            return regularStandaloneIntervalSymbol(for: interval, frequency: frequency)
        case (.short, _):
            return shortIntervalSymbol(for: interval, frequency: frequency)
        case (.full, _):
            return regularIntervalSymbol(for: interval, frequency: frequency)
        default:
            return ""
        }
    }

    private func regularIntervalSymbol(for interval: Int, frequency: SproutRecurrenceFrequency) -> String {
        return "Every " + shortIntervalSymbol(for: interval, frequency: frequency)
    }

    private func shortIntervalSymbol(for interval: Int, frequency: SproutRecurrenceFrequency) -> String {
        let dateComponents: DateComponents
        switch frequency {
        case .daily:
            dateComponents = DateComponents(day: interval)
        case .weekly:
            dateComponents = DateComponents(weekOfYear: interval)
        case .monthly:
            dateComponents = DateComponents(year: interval)
        default: dateComponents = DateComponents()
        }

        let returnString = Utility.dateComponentsFormatter.string(from: dateComponents)
        assert(returnString != nil)
        return returnString ?? ""
    }

    private func regularStandaloneIntervalSymbol(for interval: Int, frequency: SproutRecurrenceFrequency) -> String {
        return regularIntervalSymbol(for: interval, frequency: frequency).capitalized
    }

    private func shortStandaloneIntervalSymbol(for interval: Int, frequency: SproutRecurrenceFrequency) -> String {
        return shortIntervalSymbol(for: interval, frequency: frequency).capitalized
    }

    // MARK: - Specific Days
    private func daysOfTheWeekSymbol(for days: Set<Int>, style: Style, context: Context) -> String {
        let weekdayComponents = days
        let weekdaySymbols: [String]
        switch (style, context) {
        case (.short, .standalone):
            weekdaySymbols = Calendar.current.shortStandaloneWeekdaySymbols
        case (.short, _):
            weekdaySymbols = Calendar.current.shortWeekdaySymbols
        case (.full, .standalone):
            weekdaySymbols = Calendar.current.standaloneWeekdaySymbols
        case (.full, _):
            weekdaySymbols = Calendar.current.weekdaySymbols
        default:
            weekdaySymbols = Calendar.current.standaloneWeekdaySymbols
        }

        let weekdayStrings: [String] = weekdayComponents.sorted().compactMap {
            let weekdayIndex = $0 - 1
            if weekdayIndex >= weekdaySymbols.startIndex && weekdayIndex < weekdaySymbols.endIndex {
                return weekdaySymbols[weekdayIndex]
            } else {
                return nil
            }
        }

        let weekdayString: String
        switch style {
        case .short:
            weekdayString = weekdayStrings.joined(separator: ", ")
        case .full:
            let formatter = ListFormatter()
            weekdayString = "Every " + (formatter.string(from: weekdayStrings) ?? weekdayStrings.joined(separator: ", "))
        default:
            weekdayString = ""
        }

        return weekdayString
    }

    private func daysOfTheMonthSymbol(for days: Set<Int>, style: Style, context: Context) -> String {
        let dayComponents = days

        let dayStrings: [String] = dayComponents.sorted().compactMap {
            let number = NSNumber(value: $0)
            return Utility.ordinalNumberFormatter.string(from: number)
        }

        let dayString: String
        switch style {
        case .short:
            dayString = dayStrings.joined(separator: ", ")
        case .full:
            let formatter = ListFormatter()
            dayString = "Every " + (formatter.string(from: dayStrings) ?? dayStrings.joined(separator: ", "))
        default:
            dayString = ""
        }

        return dayString
    }
}

