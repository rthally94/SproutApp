//
//  Task.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/15/21.
//

import Foundation
import UIKit

enum TaskInterval: CustomStringConvertible, Hashable {
    static let listFormatter: ListFormatter = {
        let formatter = ListFormatter()
        return formatter
    }()

    static let ordinalNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter
    }()

    case none
    case daily(Int)
    case weekly(Set<Int>)
    case monthly(Set<Int>)

    var description: String {
        switch self {
            case .none:
                return "Never"
            case .daily(let interval):
                if interval > 1 {
                    return "Every \(interval) Days"
                } else {
                    return "Every Day"
                }
            case .weekly(let weekdays):
                let weekdayStrings: [String] = weekdays.sorted().compactMap {
                    if $0 >= Calendar.current.shortWeekdaySymbols.startIndex && $0 < Calendar.current.shortWeekdaySymbols.endIndex {
                        return Calendar.current.shortWeekdaySymbols[$0]
                    } else {
                        return nil
                    }
                }

                if let weekdayList = TaskInterval.listFormatter.string(from: weekdayStrings) {
                    return "Every Week on \(weekdayList)"
                } else {
                    return "Every Week"
                }
            case .monthly(let days):
                let dayStrings: [String] = days.sorted().compactMap {
                    let number = NSNumber(value: $0)
                    return TaskInterval.ordinalNumberFormatter.string(from: number)
                }

                if let dayList = TaskInterval.listFormatter.string(from: dayStrings) {
                    return "Every Month on the \(dayList)"
                } else {
                    return "Ever Month"
                }
        }
    }
}

class Task: Hashable {
    static func == (lhs: Task, rhs: Task) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

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
