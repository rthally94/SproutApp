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

        if nextReminder == nil {
            guard let context = managedObjectContext else { fatalError("Unable to get nextReminder for CareInfoItem without a set managedObjectContext") }
            nextReminder = SproutReminder.fetchOrCreateIncompleteReminder(for: self, inContext: context)
        }
        
        super.willSave()
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
        let midnightToday = Calendar.current.startOfDay(for: Date())
        guard let scheduledDate = nextReminder?.scheduledDate else { return nil }
        return scheduledDate < midnightToday ? midnightToday : scheduledDate
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
        completedReminder?.markAs(.complete, date: markedDate)

        // Create and append a new reminder with the next date
        let newReminder = SproutReminder.createDefaultReminder(inContext: context)
        newReminder.schedule = self.currentSchedule
        newReminder.scheduledDate = currentSchedule?.recurrenceRule?.nextDate(after: markedDate)
        addToReminders(newReminder)
        nextReminder = newReminder

        completion?()
    }

    func setSchedule(to newSchedule: CareSchedule?) {
        guard currentSchedule != newSchedule else { return }
        currentSchedule = newSchedule
        nextReminder?.schedule = newSchedule
    }
}

extension CareInfo: SproutCareDetail {
    var notes: String? {
        get {
            self.careNotes
        }
        set {
            self.careNotes = newValue
        }
    }

    var careType: SproutCareDetailType? {
        get {
            self.careCategory
        }
        set {
            if newValue == nil {
                self.careCategory = nil
            } else if let newCategory = newValue as? CareCategory {
                self.careCategory = newCategory
            }
        }
    }
}

extension CareInfo: Comparable {
    public static func < (lhs: CareInfo, rhs: CareInfo) -> Bool {
        switch(lhs.careCategory?.name, rhs.careCategory?.name) {
        case (.some, .some):
            return lhs.careCategory!.name! < rhs.careCategory!.name!
        case (.some, .none):
            return true
        case (.none, _):
            return false
        }
    }
}

extension CareInfo {
    static func unassignedCareInfoItemsFetchRequest() -> NSFetchRequest<CareInfo> {
        let request: NSFetchRequest<CareInfo> = CareInfo.fetchRequest()
        let sortByName = NSSortDescriptor(keyPath: \CareInfo.careCategory?.name, ascending: true)
        let sortByCreationDate = NSSortDescriptor(keyPath: \CareInfo.creationDate, ascending: true)
        request.sortDescriptors = [sortByName, sortByCreationDate]

        let plantFilterPredicate = NSPredicate(format: "%K == nil", #keyPath(CareInfo.plant))
        request.predicate = plantFilterPredicate
        return request
    }
}
