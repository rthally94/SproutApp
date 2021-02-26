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
                    let weekdayIndex = $0 - 1
                    if weekdayIndex >= Calendar.current.shortWeekdaySymbols.startIndex && weekdayIndex < Calendar.current.shortWeekdaySymbols.endIndex {
                        return Calendar.current.shortWeekdaySymbols[weekdayIndex]
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

enum TaskType: String, Hashable, CaseIterable, CustomStringConvertible {
    case watering
    case pruning
    case fertilizing
    case potting

    var description: String {
        return self.rawValue.capitalized
    }

    var icon: UIImage? {
        switch self {
            case .watering: return UIImage(systemName: "drop.fill")
            case .pruning: return UIImage(systemName: "scissors")
            case .fertilizing: return UIImage(systemName: "leaf.fill")
            case .potting: return UIImage(systemName: "rectangle.roundedbottom.fill")
        }
    }

    var accentColor: UIColor {
        switch self {
            case .watering: return .systemBlue
            case .pruning: return .systemGreen
            case .fertilizing: return .systemOrange
            case .potting: return .systemRed
        }
    }
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
    
    var interval: TaskInterval
    
    var logs: [LogEntry]
    
    internal init(id: UUID = UUID(), type: TaskType, interval: TaskInterval = .none, logs: [LogEntry]) {
        self.id = id
        self.type = type
        self.interval = interval
        self.logs = logs
    }
}

extension Task {
    static let allTasks: [Task] = [
        Task(type: .watering, interval: .weekly([2,4,6]), logs: []),
        Task(type: .pruning, interval: .daily(7), logs: []),
        Task(type: .fertilizing, interval: .monthly([25]), logs: []),
        Task(type: .potting, interval: .monthly([25]), logs: [])
    ]
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
        // TODO: Implement using interval
        guard let lastLog = logs.last else { return Date() }

        switch interval {
            case .none:
                return Date()
            case let .daily(days):
                return Calendar.current.date(byAdding: .day, value: days, to: lastLog.date) ?? Date()
            case let .weekly(weekdays):
                let lastLogWeekday = Calendar.current.component(.weekday, from: lastLog.date)
                let sortedWeekdays = weekdays.sorted()
                let nextWeekday = sortedWeekdays.first(where: { $0 > lastLogWeekday }) ?? sortedWeekdays.first
                let components = DateComponents(weekday: nextWeekday)
                return Calendar.current.nextDate(after: lastLog.date, matching: components, matchingPolicy: .nextTime) ?? Date()
            case let .monthly(days):
                let lastLogDay = Calendar.current.component(.day, from: lastLog.date)
                let sortedDays = days.sorted()
                let nextDay = sortedDays.first(where: {$0 > lastLogDay }) ?? sortedDays.first
                let components = DateComponents(day: nextDay)
                return Calendar.current.nextDate(after: lastLog.date, matching: components, matchingPolicy: .nextTime) ?? Date()
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
