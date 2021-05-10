//
//  GHTask.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/30/21.
//

import CoreData
import UIKit

public class GHTask: NSManagedObject {
    /// Creats a new task using the "Watering" template
    /// - Parameter context: The managed object context to insert the task in
    /// - Throws: Errors related to CoreData
    /// - Returns: The new, configured task
    static func defaultTask(in context: NSManagedObjectContext, ofType type: GHTaskType.TaskTypeName) throws -> GHTask {
        let task = GHTask(context: context)
        task.id = UUID()
        task.lastLogDate = nil
        task.nextCareDate = nil

        let interval = GHTaskInterval(context: context)
        interval.repeatsFrequency = GHTaskInterval.RepeatsNeverFrequency
        interval.startDate = Date()
        task.interval = interval

        task.taskType = try GHTaskType.fetchOrCreateTaskType(withName: type, inContext: context)

        task.updateNextCareDate()

        return task
    }

    public override func willSave() {
        super.willSave()

        print("TaskWillSave: Interval Updated:", interval?.isUpdated ?? false, "| Inserted:", interval?.isInserted ?? false, "| Deleted:", interval?.isDeleted ?? false)
        if (interval?.isUpdated == true || interval?.isInserted == true) {
            updateNextCareDate()
        }
    }

    /// Marks a task as complete. Increments lastLogDate and nextCareDate.
    func markAsComplete(completion: (() -> Void)? = nil) {
        managedObjectContext?.perform {
            let markedDate = Date()
            self.lastLogDate = markedDate
            self.updateNextCareDate()
            completion?()
        }
    }

    func updateNextCareDate() {
        enum TaskStatus {
            case isNew, isOnTimeOrEarly, isLate
        }

        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = today.addingTimeInterval(1*24*60*60)
        var taskStatus: TaskStatus?

        if lastLogDate == nil {
            // Task is late
            taskStatus = .isNew
        } else if let lastLogDate = lastLogDate, let nextDate = interval?.nextDate(after: lastLogDate), nextDate < today {
            taskStatus = .isLate
        } else if let lastLogDate = lastLogDate, lastLogDate < tomorrow {
            taskStatus = .isOnTimeOrEarly
        }

        let newDate: Date?
        switch taskStatus {
        case .isNew:
            // Placeholder date is the day prior
            let placeholderDate = today.addingTimeInterval(-1 * 24 * 60 * 60)
            newDate = interval?.nextDate(after: placeholderDate)
        case .isOnTimeOrEarly:
            // date is the date after the last log date
            guard let date = lastLogDate else { fatalError("Case isOnTimeOrEarly used without a lastLogDate value set.") }
            newDate = interval?.nextDate(after: date)
        case .isLate:
            // date is today
            newDate = Calendar.current.startOfDay(for: Date())
        default:
            fatalError("Unknown task state")
            break
        }

        guard newDate != nil &&
                newDate != nextCareDate else { return }
        nextCareDate = newDate
    }
}
