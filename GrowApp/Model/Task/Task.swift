//
//  Task.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/15/21.
//

import UIKit

class Task: Hashable {
    static func == (lhs: Task, rhs: Task) -> Bool {
        lhs.id == rhs.id
            && lhs.type == rhs.type
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(type)
    }

    var id: UUID
    var type: TaskType
    var careInfo: CareValue<AnyHashable>
    
    var interval: TaskInterval
    
    var logs: [LogEntry]
    
    internal init(id: UUID = UUID(), type: TaskType, careInfo: CareValue<AnyHashable>, interval: TaskInterval = .none, logs: [LogEntry]) {
        self.id = id
        self.type = type
        self.careInfo = careInfo
        self.interval = interval
        self.logs = logs
    }
}

extension Task {
    static var allTasks: [Task] {
        [
            Task(type: .watering, careInfo: .text("Top to Bottom"), interval: .weekly([2,4,6]), logs: []),
            Task(type: .pruning, careInfo: .text("When Brown"), interval: .daily(7), logs: []),
            Task(type: .fertilizing, careInfo: .text("As Needed"), interval: .monthly([25]), logs: []),
            Task(type: .potting, careInfo: .text("When Out-grown"), interval: .monthly([25]), logs: [])
        ]
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

    var lastCareDate: Date? {
        if let lastLog = logs.last {
            return Calendar.current.startOfDay(for: lastLog.date)
        } else {
            return nil
        }
    }
    
    var nextCareDate: Date {
        guard let lastCareDate = lastCareDate else { return Date() }

        switch interval {
            case .none:
                return Date()
            case let .daily(days):
                return Calendar.current.date(byAdding: .day, value: days, to: lastCareDate) ?? Date()
            case let .weekly(weekdays):
                let lastLogWeekday = Calendar.current.component(.weekday, from: lastCareDate)
                let sortedWeekdays = weekdays.sorted()
                let nextWeekday = sortedWeekdays.first(where: { $0 > lastLogWeekday }) ?? sortedWeekdays.first
                let components = DateComponents(weekday: nextWeekday)
                return Calendar.current.nextDate(after: lastCareDate, matching: components, matchingPolicy: .nextTime) ?? Date()
            case let .monthly(days):
                let lastLogDay = Calendar.current.component(.day, from: lastCareDate)
                let sortedDays = days.sorted()
                let nextDay = sortedDays.first(where: {$0 > lastLogDay }) ?? sortedDays.first
                let components = DateComponents(day: nextDay)
                return Calendar.current.nextDate(after: lastCareDate, matching: components, matchingPolicy: .nextTime) ?? Date()
        }
    }

    func isDateInInterval(_ date: Date) -> Bool {
        switch interval {
            case .none: return false
            case let .daily(days):
                if let lastLog = logs.last {
                    let numberOfDays = Calendar.current.dateComponents([.day], from: lastLog.date, to: date)
                    let remainder = numberOfDays.day ?? 0 % days
                    return remainder == 0
                } else {
                    return false
                }
            case let .weekly(weekdays):
                let inputWeekday = Calendar.current.component(.weekday, from: date)
                return weekdays.contains(inputWeekday)
            case let .monthly(days):
                let inputDay = Calendar.current.component(.day, from: date)
                return days.contains(inputDay)
        }
    }
}
