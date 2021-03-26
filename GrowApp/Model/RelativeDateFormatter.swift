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
        formatter.dateStyle = .full
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    static let relativeDateTimeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .full
        formatter.formattingContext = .beginningOfSentence
        return formatter
    }()
    
    func string(from date: Date) -> String {
        let interval = Calendar.current.dateComponents([.day], from: Date(), to: date).day!
        if interval >= -1 && interval <= 1 {
            return RelativeDateFormatter.dateFormatter.string(from: date)
        } else {
            return RelativeDateFormatter.relativeDateTimeFormatter.localizedString(for: date, relativeTo: Date())
        }
    }
}
