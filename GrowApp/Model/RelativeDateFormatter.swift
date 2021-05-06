//
//  RelativeDateFormatter.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/24/21.
//

import Foundation

class RelativeDateFormatter: Formatter {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    static let dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day]
        formatter.formattingContext = .middleOfSentence
        formatter.unitsStyle = .full
        return formatter
    }()

    static let relativeDateTimeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .numeric
        formatter.unitsStyle = .full
        formatter.formattingContext = .standalone
        return formatter
    }()
    
    func string(from date: Date) -> String {
        let today = Calendar.current.startOfDay(for: Date())
        let interval = Calendar.current.dateComponents([.day], from: today, to: date).day!
        if interval >= -1 && interval <= 1 {
            return RelativeDateFormatter.dateFormatter.string(from: date)
        } else if interval < 30, let dateString = RelativeDateFormatter.dateComponentsFormatter.string(from: today, to: date) {
            return "In " + dateString
        } else {
            return RelativeDateFormatter.relativeDateTimeFormatter.localizedString(for: date, relativeTo: today)
        }
    }
}
