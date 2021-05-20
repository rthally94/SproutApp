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

        info.careCategory = try CareCategory.fetchOrCreateCategory(withName: type, inContext: context)

        return info
    }


    public override func willSave() {
        if plant == nil {
            managedObjectContext?.delete(self)
            print("Unusued CareInfo Deleted")
        }
        
        super.willSave()
    }

    var nextReminder: SproutReminder {
        guard let context = managedObjectContext else { fatalError("Unable to get nextReminder for CareInfoItem without a set managedObjectContext") }
        return SproutReminder.fetchOrCreateIncompleteReminder(for: self, inContext: context)
    }

    var lastCompletedReminder: SproutReminder? {
        guard let context = managedObjectContext else { fatalError("unable to get lastCompletedReminder for CareInfoItem weithout a set managedObjectContext") }
        let request = SproutReminder.completedRemindersFetchRequest(for: self, startingOn: nil, endingBefore: nil)
        do {
            return try context.fetch(request).first
        } catch {
            print("Unable to fetch lastCompletedReminder for \(self): \(error)")
            return nil
        }
    }

    @objc var nextCareDate: Date? {
        nextReminder.scheduledDate
    }

    @objc var lastLogDate: Date? {
        lastCompletedReminder?.statusDate
    }

    /// Marks a task as complete. Increments lastLogDate and nextCareDate.
    func markAsComplete(inContext context: NSManagedObjectContext? = nil, completion: (() -> Void)? = nil) {
        guard let context = context ?? self.managedObjectContext else { fatalError("Unable to mark CareInfoItem as complete without a managedObjectContext.")}

        // Mark the current reminder as complete
        let markedDate = Date()
        let completedReminder = nextReminder
        completedReminder.markAs(.complete, date: markedDate)

        // Create and append a new reminder with the next date
        let nextReminder = SproutReminder.createDefaultReminder(inContext: context)
        nextReminder.schedule = self.currentSchedule
        nextReminder.scheduledDate = currentSchedule?.recurrenceRule?.nextDate(after: markedDate)
        addToReminders(nextReminder)

        completion?()
    }

    func setSchedule(to newSchedule: CareSchedule?) throws {
        try nextReminder.updateSchedule(to: newSchedule)
        currentSchedule = newSchedule
    }
}
