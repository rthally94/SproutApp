//
//  CareInfo.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/30/21.
//

import CoreData
import UIKit

public class CareInfo: NSManagedObject {
    /// Creats a new task using the "Watering" template
    /// - Parameter context: The managed object context to insert the task in
    /// - Throws: Errors related to CoreData
    /// - Returns: The new, configured task
    static func createDefaultInfoItem(in context: NSManagedObjectContext, ofType type: CareCategory.TaskTypeName) throws -> CareInfo {
        let info = CareInfo(context: context)
        info.id = UUID()
        info.creationDate = Date()

        info.lastLogDate = nil
        info.nextCareDate = nil

        info.careCategory = try CareCategory.fetchOrCreateCategory(withName: type, inContext: context)
        info.updateNextCareDate()

        return info
    }

    public override func willSave() {
        if plant == nil {
            managedObjectContext?.delete(self)
            print("Unusued CareInfo Deleted")
        }

        if !isDeleted {
            print("TaskWillSave: Interval Updated:", careSchedule?.isUpdated ?? false, "| Inserted:", careSchedule?.isInserted ?? false, "| Deleted:", careSchedule?.isDeleted ?? false)
            if (careSchedule?.isUpdated == true || careSchedule?.isInserted == true) {
                updateNextCareDate()
            }
        }

        super.willSave()
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
        } else if let lastLogDate = lastLogDate, let nextDate = careSchedule?.recurrenceRule?.nextDate(after: lastLogDate), nextDate < today {
            taskStatus = .isLate
        } else if let lastLogDate = lastLogDate, lastLogDate < tomorrow {
            taskStatus = .isOnTimeOrEarly
        }

        let newDate: Date?
        switch taskStatus {
        case .isNew:
            // Placeholder date is the day prior
            let placeholderDate = today.addingTimeInterval(-1 * 24 * 60 * 60)
            newDate = careSchedule?.recurrenceRule?.nextDate(after: placeholderDate)
        case .isOnTimeOrEarly:
            // date is the date after the last log date
            guard let date = lastLogDate else { fatalError("Case isOnTimeOrEarly used without a lastLogDate value set.") }
            newDate = careSchedule?.recurrenceRule?.nextDate(after: date)
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
