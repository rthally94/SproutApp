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
        task.nextCareDate = Calendar.current.startOfDay(for: Date())

        let interval = GHTaskInterval(context: context)
        interval.repeatsFrequency = GHTaskInterval.RepeatsNeverFrequency
        interval.startDate = Date()
        task.interval = interval

        task.taskType = try GHTaskType.fetchOrCreateTaskType(withName: type, inContext: context)
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
        managedObjectContext?.persist {
            let markedDate = Date()
            self.lastLogDate = markedDate
            self.updateNextCareDate()
        }
    }

    func updateNextCareDate() {
        let previousCareDate: Date
        if let lastLogDate = lastLogDate, Calendar.current.isDateInToday(lastLogDate) {
            // Last Log is Today -> Next is after today
            previousCareDate = lastLogDate
        } else {
            let today = Calendar.current.startOfDay(for: Date())
            previousCareDate = today.addingTimeInterval(-1 * 24 * 60 * 60)
        }

        let nextDate = interval?.nextDate(after: previousCareDate)
        if nextCareDate == nil {
            print("Updating Next Care Date")
            nextCareDate = nextDate
        }
        else if let nextCareDate = nextCareDate, let nextDate = nextDate, nextCareDate == Calendar.current.startOfDay(for: nextDate) {
            print("Updating Next Care Date")
            self.nextCareDate = Calendar.current.startOfDay(for: nextDate)
        } else {
            print("nextCareDate does not need updating. Value is not withing delta for change")
        }
    }
}
