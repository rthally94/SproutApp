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
    var valuesStyle: Style = .none
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

        return frequencyText
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
            return "daily"
        case .weekly:
            return "weekly"
        case .monthly:
            return "monthly"
        case .never:
            return "never"
        }
    }

    func shortFrequencySymbol(for frequency: SproutRecurrenceFrequency) -> String {
        switch frequency {
        case .daily:
            return "daily"
        case .weekly:
            return "wkly"
        case .monthly:
            return "mthly"
        case .never:
            return "never"
        }
    }

    func regularStandaloneFrequencySymbol(for frequency: SproutRecurrenceFrequency) -> String {
        return regularFrequencySymbol(for: frequency).capitalized
    }

    func shortStandaloneFrequencySymbol(for frequency: SproutRecurrenceFrequency) -> String {
        return shortFrequencySymbol(for: frequency).uppercased()
    }

    // MARK: - Interval
    private func intervalSymbol(for interval: Int, style: Style, context: Context) -> String {
        let parameters = (style, context)
        switch parameters {
        default:
            return ""
        }
    }
}

