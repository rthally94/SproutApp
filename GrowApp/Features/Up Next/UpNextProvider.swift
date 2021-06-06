//
//  TasksProvider.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/29/21.
//

import CoreData
import UIKit

class UpNextProvider: NSObject {
    let moc: NSManagedObjectContext
    fileprivate let fetchedResultsController: NSFetchedResultsController<SproutCareTaskMO>

    @Published var scheduledReminders: [Date: [SproutCareTaskMO]]?
    @Published var unscheduledReminders: [SproutCareTaskMO]?

    init(managedObjectContext: NSManagedObjectContext) {
        self.moc = managedObjectContext

//        let today = Calendar.current.startOfDay(for: Date())
//        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)

        let request: NSFetchRequest<SproutCareTaskMO> = SproutCareTaskMO.fetchRequest()
        let sortByDueDate = NSSortDescriptor(keyPath: \SproutCareTaskMO.dueDate, ascending: true)
        let sortByPlantName = NSSortDescriptor(keyPath: \SproutCareTaskMO.plant?.nickname, ascending: true)
        let sortByTaskType = NSSortDescriptor(keyPath: \SproutCareTaskMO.taskType, ascending: true)
        request.sortDescriptors = [sortByDueDate, sortByPlantName, sortByTaskType]

        let isNotTemplatePredicate = NSPredicate(format: "%K == false", #keyPath(SproutCareTaskMO.isTemplate))
        let isIncompletePredicate = NSPredicate(format: "%K == nil", #keyPath(SproutCareTaskMO.historyLog))

        let midnightToday = Calendar.current.startOfDay(for: Date())
        let midnightTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: midnightToday)!
        let isCompletedToday = NSPredicate(format: "%K >= %@ && %K < %@", #keyPath(SproutCareTaskMO.historyLog.statusDate), midnightToday as NSDate, #keyPath(SproutCareTaskMO.historyLog.statusDate), midnightTomorrow as NSDate)

        let taskTypePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [isIncompletePredicate, isCompletedToday])
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [isNotTemplatePredicate, taskTypePredicate])

        let count = try? moc.count(for: request)
        print("Objects: \(count ?? -1)")

        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)

        super.init()

        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
        updateProperties()
    }

    func object(at indexPath: IndexPath) -> SproutCareTaskMO {
        return fetchedResultsController.object(at: indexPath)
    }

    func object(withID id: NSManagedObjectID) -> AnyObject? {
        let task = moc.object(with: id)
        return task
    }

    private func updateProperties() {
        print("FRC: Updating...")
        scheduledReminders = fetchedResultsController.fetchedObjects?.reduce(into: [Date: [SproutCareTaskMO]](), { scheduledReminders, reminder in
            if let log = reminder.historyLog, let date = log.statusDate {
                let midnightOfDate = Calendar.current.startOfDay(for: date)
                scheduledReminders[midnightOfDate, default: [] ].append(reminder)
            } else if let date = reminder.dueDate, reminder.hasSchedule {
                let midnightOfDate = Calendar.current.startOfDay(for: date)
                scheduledReminders[midnightOfDate, default: [] ].append(reminder)
            }
        })
        print("FRC: scheduledReminder Updated: \(scheduledReminders)")

        unscheduledReminders = fetchedResultsController.fetchedObjects?.filter({ reminder in
            !reminder.hasSchedule
        })
        print("FRC: unscheduledReminder Updated: \(unscheduledReminders)")
        print("FRC: DONE")
    }
}

extension UpNextProvider: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateProperties()
    }
}


