//
//  Task.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/15/21.
//

import UIKit
enum TaskStatus: Int {
    case unscheduled
    case needsCare
    case complete
}


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
    
    private var _startingDate: Date = Date()
    var startingDate: Date {
        get {
            return _startingDate
        }
        set {
            _startingDate = Calendar.current.startOfDay(for: newValue)
        }
    }
    
    var logs: [LogEntry]
    
    internal init(id: UUID = UUID(), type: TaskType, careInfo: CareValue<AnyHashable>, interval: TaskInterval = .none, startingOn startingDate: Date = Date(), logs: [LogEntry]) {
        self.id = id
        self.type = type
        self.careInfo = careInfo
        self.interval = interval
        self.logs = logs
        self.startingDate = startingDate
    }
}

extension Task {
    static var allTasks: [Task] {
        [
            Task(type: .watering, careInfo: .text("Top to Bottom"), interval: .weekly([2,4,6]), logs: []),
            Task(type: .pruning, careInfo: .text("When Brown"), interval: .daily(15), logs: []),
            Task(type: .fertilizing, careInfo: .text("As Needed"), interval: .monthly([25]), logs: []),
            Task(type: .potting, careInfo: .text("When Out-grown"), interval: .monthly([25]), logs: [])
        ]
    }
}

extension Task {
    //MARK: Actions
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

}

extension Task {
    //MARK: Convenence Methods
    var lastCareDate: Date? {
        if let lastLog = logs.last {
            return Calendar.current.startOfDay(for: lastLog.date)
        } else {
            return nil
        }
    }
    
    func nextCareDate(after date: Date) -> Date? {
        guard date >= startingDate else { return startingDate }
        
        switch interval {
            case .none:
                return nil
            case let .daily(days):
                // Calculate elapsed days since start to desired day
                let daysSinceStartingDate = Calendar.current.dateComponents([.day], from: startingDate, to: date)
                
                // Divide by interval to determine the number of interval periods that have elapsed.
                let intervalsSinceStartingDate = daysSinceStartingDate.day ?? 0 / days
                
                // Get the Date N + 1 interval periods from the starting date
                let nextIntervalDate = Calendar.current.date(byAdding: .day, value: (intervalsSinceStartingDate + 1) * days, to: startingDate)
                return nextIntervalDate
                
            case let .weekly(weekdays):
                // Get weekday from desired date
                let weekdayToCheck = Calendar.current.component(.weekday, from: date)
                
                // Get the weekday after the desired date
                let sortedWeekdays = weekdays.sorted()
                let nextWeekday = sortedWeekdays.first(where: { $0 > weekdayToCheck }) ?? sortedWeekdays.first
                
                // Calcualte the date of the next weekday
                let components = DateComponents(weekday: nextWeekday)
                return Calendar.current.nextDate(after: date, matching: components, matchingPolicy: .nextTime)
                
            case let .monthly(days):
                // Get the day of the desired date
                let desiredDay = Calendar.current.component(.day, from: date)
                
                // Get the day after the desired date
                let sortedDays = days.sorted()
                let nextDay = sortedDays.first(where: {$0 > desiredDay }) ?? sortedDays.first
                
                // Calculate the date of the next day
                let components = DateComponents(day: nextDay)
                return Calendar.current.nextDate(after: date, matching: components, matchingPolicy: .nextTime)
        }
    }
    
    func previousCareDate(before date: Date) -> Date? {
        guard date >= startingDate else { return startingDate }
        
        switch interval {
            case .none:
                return nil
            case let .daily(days):
                // Calculate elapsed days since start to desired day
                let daysSinceStartingDate = Calendar.current.dateComponents([.day], from: startingDate, to: date)
                
                // Divide by interval to determine the number of interval periods that have elapsed.
                let intervalsSinceStartingDate = daysSinceStartingDate.day ?? 0 / days
                
                if intervalsSinceStartingDate > 0 {
                    // Get the Date N + 1 interval periods from the starting date
                    let nextIntervalDate = Calendar.current.date(byAdding: .day, value: (intervalsSinceStartingDate - 1) * days, to: startingDate)
                    return nextIntervalDate
                } else {
                    return startingDate
                }
                
            case let .weekly(weekdays):
                // Get weekday from desired date
                let weekdayToCheck = Calendar.current.component(.weekday, from: date)
                
                // Get the weekday after the desired date
                let sortedWeekdays = weekdays.sorted().reversed()
                let nextWeekday = sortedWeekdays.first(where: { $0 < weekdayToCheck }) ?? sortedWeekdays.first
                
                // Calcualte the date of the next weekday
                let components = DateComponents(weekday: nextWeekday)
                if let previousDate = Calendar.current.nextDate(after: date, matching: components, matchingPolicy: .nextTime, direction: .backward), previousDate >= startingDate {
                    return previousDate
                } else {
                    return startingDate
                }
                
            case let .monthly(days):
                // Get the day of the desired date
                let desiredDay = Calendar.current.component(.day, from: date)
                
                // Get the day after the desired date
                let sortedDays = days.sorted().reversed()
                let nextDay = sortedDays.first(where: {$0 > desiredDay }) ?? sortedDays.first
                
                // Calculate the date of the next day
                let components = DateComponents(day: nextDay)
                if let previousDate = Calendar.current.nextDate(after: date, matching: components, matchingPolicy: .nextTime, direction: .backward), previousDate >= startingDate {
                    return previousDate
                } else {
                    return startingDate
                }
        }
    }

    func isDateInInterval(_ date: Date) -> Bool {
        // Test date must be after the starting date
        guard date >= startingDate else { return false }
        
        switch interval {
            case .none: return true
            case let .daily(days):
                // Calculate elapsed days since start to desired day
                guard let daysSinceStartingDate = Calendar.current.dateComponents([.day], from: startingDate, to: date).day else { return false }
                
                // Divide by interval to determine the number of interval periods that have elapsed.
                let remainder = daysSinceStartingDate % days
                return remainder == 0
                
            case let .weekly(weekdays):
                let inputWeekday = Calendar.current.component(.weekday, from: date)
                return weekdays.contains(inputWeekday)
                
            case let .monthly(days):
                let inputDay = Calendar.current.component(.day, from: date)
                return days.contains(inputDay)
        }
    }
    
    func isLate() -> Bool {
        if let lastCareDate = lastCareDate, let nextCareDate = nextCareDate(after: lastCareDate), nextCareDate < Calendar.current.startOfDay(for: Date()) {
            return true
        } else {
            return false
        }
    }
    
    func currentStatus() -> TaskStatus {
        if let lastCareDate = lastCareDate, Calendar.current.isDateInToday(lastCareDate) {
            return .complete
        } else if interval == .none {
            return .unscheduled
        } else {
            return .needsCare
        }
    }
}
