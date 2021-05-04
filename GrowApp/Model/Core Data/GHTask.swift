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
        task.nextCareDate = Date()

        let interval = GHTaskInterval(context: context)
        interval.repeatsFrequency = GHTaskInterval.RepeatsNeverFrequency
        interval.startDate = Date()
        task.interval = interval

        task.taskType = try GHTaskType.fetchOrCreateTaskType(withName: type, inContext: context)
        return task
    }

    /// Marks a task as complete. Increments lastLogDate and nextCareDate.
    func markAsComplete() {
        let markedDate = Date()
        lastLogDate = markedDate

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [unowned self] in
            self.nextCareDate = interval?.nextDate(after: markedDate)
        }
    }

    /// String the represents the nextCareDate relative to today's date
    @objc var relativeNextCareDateString: String {
        let formatter = Utility.relativeDateFormatter
        assert(nextCareDate != nil, "WARNING: nextCareDate for task \(self) is nil. A value needs to be set.")
        if let nextCareDate = nextCareDate {
            return formatter.string(from: nextCareDate)
        } else {
            return "NO DATE"
        }
    }
}
