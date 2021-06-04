//
//  SproutCareTaskMO.swift
//  GrowApp
//
//  Created by Ryan Thally on 6/2/21.
//

import CoreData
import UIKit

enum NSManagedObjectError: Error {
    case noManagedObjectContextError
}

enum SproutCareTaskMOError: Error {
    case taskNotLoggedError
}

class SproutCareTaskMO: NSManagedObject {
    enum SproutCareTaskType: String {
        case watering

        var displayName: String {
            return self.rawValue.capitalized
        }

        var icon: UIImage? {
            switch self {
            case .watering:
                return UIImage(systemName: "drop.fill")
            }
        }
    }

    static func createNewTask(type: SproutCareTaskType, in context: NSManagedObjectContext, completion: @escaping (SproutCareTaskMO) -> Void) {
        context.perform {
            let newTask = SproutCareTaskMO(context: context)
            newTask.id = UUID().uuidString
            newTask.creationDate = Date()
            newTask.taskType = type.rawValue
            newTask.hasSchedule = false
            newTask.hasRecurrenceRule = false

            completion(newTask)
        }
    }

    static func createNewTask(from existingTask: SproutCareTaskMO, completion: @escaping (SproutCareTaskMO) -> Void ) throws {
        guard let context = existingTask.managedObjectContext else { throw NSManagedObjectError.noManagedObjectContextError }
        guard existingTask.historyLog != nil else { throw SproutCareTaskMOError.taskNotLoggedError }

        context.performAndWait {
            let newTask = SproutCareTaskMO(context: context)
            newTask.id = UUID().uuidString
            newTask.creationDate = Date()

            newTask.taskType = existingTask.taskType

            newTask.hasSchedule = existingTask.hasSchedule
            newTask.startDate = existingTask.startDate
            newTask.dueDate = existingTask.dueDate

            newTask.hasRecurrenceRule = existingTask.hasRecurrenceRule
            newTask.recurrenceDaysOfWeek = existingTask.recurrenceDaysOfWeek
            newTask.recurrenceDaysOfMonth = existingTask.recurrenceDaysOfMonth
            newTask.recurrenceFirstDayOfWeek = existingTask.recurrenceFirstDayOfWeek
            newTask.recurrenceFrequency = existingTask.recurrenceFrequency
            newTask.recurrenceInterval = existingTask.recurrenceInterval

            newTask.plant = existingTask.plant
            completion(newTask)
        }
    }

    var schedule: SproutCareTaskSchedule? {
        get {
            guard hasSchedule, let startDate = startDate, let dueDate = dueDate else { return nil }
            return SproutCareTaskSchedule(startDate: startDate, dueDate: dueDate, recurrenceRule: recurrenceRule)
        }
        set {
            hasSchedule = newValue != nil
            startDate = newValue?.startDate
            dueDate = newValue?.dueDate

            recurrenceRule = newValue?.recurrenceRule
        }
    }

    var recurrenceRule: SproutCareTaskRecurrenceRule? {
        get {
            guard hasRecurrenceRule else { return nil }
            switch recurrenceFrequency {
            case SproutCareTaskRecurrenceRule.daily(0).frequency:
                return SproutCareTaskRecurrenceRule.daily(Int(recurrenceInterval))
            case SproutCareTaskRecurrenceRule.weekly(0).frequency:
                return SproutCareTaskRecurrenceRule.weekly(Int(recurrenceInterval), recurrenceDaysOfWeek)
            case SproutCareTaskRecurrenceRule.monthly(0).frequency:
                return SproutCareTaskRecurrenceRule.monthly(Int(recurrenceInterval), recurrenceDaysOfMonth)
            default:
                return nil
            }
        }
        set {
            hasRecurrenceRule = newValue != nil
            recurrenceDaysOfWeek = newValue?.daysOfWeek
            recurrenceDaysOfMonth = newValue?.daysOfMonth
            recurrenceFirstDayOfWeek = Int16(Calendar.current.firstWeekday)
            recurrenceFrequency = newValue?.frequency
            recurrenceInterval = Int16(newValue?.interval ?? 1)
        }
    }

    var taskTypeProperties: SproutCareTaskType? {
        return SproutCareTaskType(rawValue: taskType ?? "")
    }
}

extension SproutCareTaskMO {
    typealias SproutTaskStatus = SproutCareHistoryMO.SproutTaskStatus

    func markAs(_ status: SproutTaskStatus, completion: @escaping () -> Void ) throws {
        guard let context = managedObjectContext else { throw NSManagedObjectError.noManagedObjectContextError }
        context.perform {
            // Create a new log and assign self as the parent
            do {
                try SproutCareHistoryMO.createNewLog(for: self, status: .complete, completion: { newLog -> Void in
                    // Create a new task, using self as the template
                    do {
                        try SproutCareTaskMO.createNewTask(from: self, completion: { newTask in
                            // Update to the next date if able
                            if let existingSchedule = newTask.schedule, let recurrenceRule = existingSchedule.recurrenceRule {
                                newTask.schedule = .init(startDate: Date(), recurrenceRule: recurrenceRule)
                            }
                            completion()
                        })
                    } catch {
                        print("Error creating new task: \(error)")
                        context.rollback()
                    }
                })
            } catch {
                print("Error creating new task: \(error)")
                context.rollback()
            }
        }
    }
}

extension SproutCareTaskMO: Comparable {
    static func < (lhs: SproutCareTaskMO, rhs: SproutCareTaskMO) -> Bool {
        lhs.historyLog < rhs.historyLog
            && lhs.taskType < rhs.taskType
            && lhs.plant < rhs.plant
    }
}
