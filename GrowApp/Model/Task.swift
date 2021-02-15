//
//  Task.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/15/21.
//

import Foundation
import UIKit

enum TaskInterval {
    case none
    case daily(Int)
    case weekly(Set<Int>)
    case monthly(Set<Int>)
}

class Task {
    var id: UUID
    var name: String
    var iconImage: UIImage?
    var accentColor: UIColor
    
    var interval: TaskInterval
    
    var logs: [LogEntry]
    
    internal init(id: UUID = UUID(), name: String, iconImage: UIImage? = nil, accentColor: UIColor = .systemBlue, interval: TaskInterval = .none, logs: [LogEntry]) {
        self.id = id
        self.name = name
        self.iconImage = iconImage
        self.accentColor = accentColor
        self.interval = interval
        self.logs = logs
    }
}

extension Task {
    
    func logCompletedCare(on date: Date) {
        logCare(as: .complete, on: date)
    }
    
    func logSkippedCare(on date: Date) {
        logCare(as: .skipped, on: date)
    }
    
    func logCare(as state: LogState, on date: Date) {
        let log = LogEntry(id: UUID(), task: self, state: state, date: date)
        logs.append(log)
    }
    
    var nextCareDate: Date {
        if let lastLog = logs.last, let next = Calendar.current.date(byAdding: .day, value: 1, to: lastLog.date) {
            return Calendar.current.startOfDay(for: next)
        } else {
            return Calendar.current.startOfDay(for: Date())
        }
    }
}
