//
//  SproutCareTaskMO+SwiftAdapters.swift
//  
//
//  Created by Ryan Thally on 6/26/21.
//

import Foundation

public extension SproutCareTaskMO {
    // MARK: - Instance Properties
    var markStatus: SproutMarkStatus {
        get {
            guard let statusKey = status, let mark = SproutMarkStatus(rawValue: statusKey) else { return .due }
            return mark
        }
        set {
            status = newValue.rawValue
            switch newValue {
            case .due:
                statusDate = dueDate
            default:
                statusDate = Date()
            }

            updateUpNextGroupingDate()
            
        }
    }

    var schedule: SproutCareTaskSchedule? {
        get {
            guard let startDate = startDate, let dueDate = dueDate else { return nil }
            return SproutCareTaskSchedule(startDate: startDate, dueDate: dueDate, recurrenceRule: recurrenceRule)
        }
        set {
            guard markStatus == .due else { return }

            hasSchedule = newValue != nil
            startDate = newValue?.startDate

            dueDate = newValue?.dueDate
            recurrenceRule = newValue?.recurrenceRule

            markStatus = .due
        }
    }

    private(set) var recurrenceRule: SproutCareTaskRecurrenceRule? {
        get {
            switch recurrenceFrequency {
            case "daily":
                return SproutCareTaskRecurrenceRule.daily(Int(recurrenceInterval))
            case "weekly":
                return SproutCareTaskRecurrenceRule.weekly(Int(recurrenceInterval), recurrenceDaysOfWeek)
            case "monthly":
                return SproutCareTaskRecurrenceRule.monthly(Int(recurrenceInterval), recurrenceDaysOfMonth)
            default:
                return nil
            }
        }
        set {
            switch newValue {
            case let .daily(interval):
                hasRecurrenceRule = true
                recurrenceFrequency = "daily"
                recurrenceInterval = Int64(interval)
                recurrenceDaysOfWeek = nil
                recurrenceDaysOfMonth = nil
            case let .weekly(interval, weekdays):
                hasRecurrenceRule = true
                recurrenceFrequency = "weekly"
                recurrenceInterval = Int64(interval)
                recurrenceDaysOfWeek = weekdays
                recurrenceDaysOfMonth = nil
            case let .monthly(interval, days):
                hasRecurrenceRule = true
                recurrenceFrequency = "monthly"
                recurrenceInterval = Int64(interval)
                recurrenceDaysOfWeek = nil
                recurrenceDaysOfMonth = days
            default:
                hasRecurrenceRule = false
                recurrenceFrequency = nil
                recurrenceInterval = 1
                recurrenceDaysOfWeek = nil
                recurrenceDaysOfMonth = nil

            }
        }
    }
}
