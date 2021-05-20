//
//  Utility.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/9/21.
//

import Foundation

final class Utility { }

extension Utility {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        return formatter
    }()

    static let dateComponentsFormatter: DateComponentsFormatter = {
       let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.month, .weekOfMonth, .day]
        formatter.maximumUnitCount = 1
        formatter.formattingContext = .beginningOfSentence
        formatter.unitsStyle = .full
        return formatter
    }()

    static let relativeDateFormatter: RelativeDateFormatter = {
        let formatter = RelativeDateFormatter()
        return formatter
    }()

    static let ordinalNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        formatter.formattingContext = .middleOfSentence
        return formatter
    }()

    static let currentScheduleFormatter: CareScheduleFormatter = {
        let formatter = CareScheduleFormatter()
        formatter.frequencyStyle = .short
        formatter.valuesStyle = .short
        formatter.formattingContext = .standalone
        return formatter
    }()
}
