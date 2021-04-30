//
//  GHTask.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/30/21.
//

import CoreData
import UIKit

public class GHTask: NSManagedObject {
    static func wateringTask(in context: NSManagedObjectContext) throws -> GHTask {
        let task = GHTask(context: context)
        task.id = UUID()
        task.lastLogDate = nil
        task.nextCareDate = Date()

        let interval = GHTaskInterval(context: context)
        interval.repeatsFrequency = GHTaskInterval.RepeatsNeverFrequency
        interval.startDate = Date()
        task.interval = interval

        let taskType = try GHTaskType.fetchOrCreateTaskType(withName: GHTaskType.WateringTaskType, inContext: context)
        let icon = GHIcon(context: context)
        icon.symbolName = "drop.fill"
        icon.color = UIColor.systemBlue
        taskType.icon = icon

        return task
    }

    func markAsComplete() {
        let markedDate = Date()
        lastLogDate = markedDate
        nextCareDate = interval?.nextDate(after: markedDate)
    }
}
