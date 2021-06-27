//
//  RelativeDateFormatter.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/24/21.
//

import Foundation

public class RelativeDateFormatter: Formatter {
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
    
    public func string(from date: Date) -> String {
        let today = Calendar.current.startOfDay(for: Date())
        let daysToGo = Calendar.current.dateComponents([.day], from: today, to: date).day!
        if daysToGo >= -1 && daysToGo <= 1 {
            // Display Yesterday, Today, Tomorrow
            return RelativeDateFormatter.dateFormatter.string(from: date)
        } else if daysToGo < 30 {
            let isForward = daysToGo > 0
            if isForward, let dateString = RelativeDateFormatter.dateComponentsFormatter.string(from: today, to: date) {
                return "In \(dateString)"
            } else if let dateString = RelativeDateFormatter.dateComponentsFormatter.string(from: date, to: today) {
                return "\(dateString) ago"
            } else {
                return ""
            }
        } else {
            return RelativeDateFormatter.relativeDateTimeFormatter.localizedString(for: date, relativeTo: today)
        }
    }
}
