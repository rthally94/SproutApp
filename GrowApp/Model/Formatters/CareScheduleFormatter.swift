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
        guard let obj = obj as? SproutCareTaskSchedule else { return nil }
        return string(for: obj)
    }

    func string(from schedule: SproutCareTaskSchedule) -> String {
        let frequencyText: String
        if let rule = schedule.recurrenceRule {
            frequencyText = recurrenceRuleFormatter.string(from: rule)
        } else {
            frequencyText = ""
        }
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
        guard let obj = obj as? SproutCareTaskRecurrenceRule else { return nil }
        return string(for: obj)
    }

    func string(from rule: SproutCareTaskRecurrenceRule) -> String {
        let frequencyText: String
        let valueText: String

        switch rule {
        case .daily(let interval):
            frequencyText = frequencySymbol(for: rule, style: frequencyStyle, context: formattingContext)
            valueText = intervalSymbol(for: interval, frequency: rule, style: frequencyStyle, context: formattingContext)

        case .weekly(let interval, let weekdays) where interval == 1 && weekdays?.isEmpty == false:
            frequencyText = frequencySymbol(for: rule, style: frequencyStyle, context: formattingContext)
            valueText = daysOfTheWeekSymbol(for: weekdays!, style: frequencyStyle, context: formattingContext)

        case .weekly(let interval, _):
            frequencyText = frequencySymbol(for: rule, style: frequencyStyle, context: formattingContext)
            valueText = intervalSymbol(for: interval, frequency: rule, style: frequencyStyle, context: formattingContext)

        case .monthly(let interval, let days) where interval == 1 && days?.isEmpty == false:
            frequencyText = frequencySymbol(for: rule, style: frequencyStyle, context: formattingContext)
            valueText = daysOfTheMonthSymbol(for: days!, style: frequencyStyle, context: formattingContext)

        case .monthly(let interval, _):
            frequencyText = frequencySymbol(for: rule, style: frequencyStyle, context: formattingContext)
            valueText = intervalSymbol(for: interval, frequency: rule, style: frequencyStyle, context: formattingContext)
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
    private func frequencySymbol(for frequency: SproutCareTaskRecurrenceRule, style: Style, context: Context) -> String {
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

    func regularFrequencySymbol(for frequency: SproutCareTaskRecurrenceRule) -> String {
        switch frequency {
        case .daily:
            return "Every day"
        case .weekly:
            return "Every week"
        case .monthly:
            return "Every month"
        }
    }

    func shortFrequencySymbol(for frequency: SproutCareTaskRecurrenceRule) -> String {
        switch frequency {
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        }
    }

    func regularStandaloneFrequencySymbol(for frequency: SproutCareTaskRecurrenceRule) -> String {
        return regularFrequencySymbol(for: frequency).capitalized
    }

    func shortStandaloneFrequencySymbol(for frequency: SproutCareTaskRecurrenceRule) -> String {
        return shortFrequencySymbol(for: frequency).capitalized
    }

    // MARK: - Interval
    private func intervalSymbol(for interval: Int, frequency: SproutCareTaskRecurrenceRule, style: Style, context: Context) -> String {
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

    private func regularIntervalSymbol(for interval: Int, frequency: SproutCareTaskRecurrenceRule) -> String {
        return "Every " + shortIntervalSymbol(for: interval, frequency: frequency)
    }

    private func shortIntervalSymbol(for interval: Int, frequency: SproutCareTaskRecurrenceRule) -> String {
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

    private func regularStandaloneIntervalSymbol(for interval: Int, frequency: SproutCareTaskRecurrenceRule) -> String {
        return regularIntervalSymbol(for: interval, frequency: frequency).capitalized
    }

    private func shortStandaloneIntervalSymbol(for interval: Int, frequency: SproutCareTaskRecurrenceRule) -> String {
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

