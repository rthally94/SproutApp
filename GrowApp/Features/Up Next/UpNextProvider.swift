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
    fileprivate var fetchedResultsController: NSFetchedResultsController<SproutCareTaskMO>!

    @Published var snapshot: NSDiffableDataSourceSnapshot<String, NSManagedObjectID>?

    @Published var scheduledReminders: [Date: [SproutCareTaskMO]]?
    @Published var unscheduledReminders: [SproutCareTaskMO]?

    var doesShowCompletedTasks: Bool = false {
        didSet {
            fetchedResultsController.fetchRequest.predicate = makePredicate()
            try? fetchedResultsController.performFetch()
        }
    }

    init(managedObjectContext: NSManagedObjectContext) {
        self.moc = managedObjectContext
        super.init()

        let request = makeFetchRequest()

        let count = try? moc.count(for: request)
        print("Objects: \(count ?? -1)")

        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: #keyPath(SproutCareTaskMO.displayDate), cacheName: nil)

        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
        updateProperties()
    }


    func object(at indexPath: IndexPath) -> SproutCareTaskMO {
        return fetchedResultsController.object(at: indexPath)
    }

    func task(withID id: NSManagedObjectID) -> SproutCareTaskMO? {
        return moc.object(with: id) as? SproutCareTaskMO
    }

    func plant(withID id: NSManagedObjectID) -> SproutPlantMO? {
        return moc.object(with: id) as? SproutPlantMO
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

    private func makeFetchRequest() -> NSFetchRequest<SproutCareTaskMO> {
        let request: NSFetchRequest<SproutCareTaskMO> = SproutCareTaskMO.fetchRequest()
        let sortByDisplayDate = NSSortDescriptor(keyPath: \SproutCareTaskMO.displayDate, ascending: true)
        let sortByPlantName = NSSortDescriptor(keyPath: \SproutCareTaskMO.plant?.nickname, ascending: true)
        let sortByTaskType = NSSortDescriptor(keyPath: \SproutCareTaskMO.taskType, ascending: true)
        request.sortDescriptors = [sortByDisplayDate, sortByPlantName, sortByTaskType]
        request.predicate = makePredicate()
        return request
    }

    private func makePredicate() -> NSPredicate {
        // Hides all template tasks
        let isNotTemplatePredicate = NSPredicate(format: "%K == false", #keyPath(SproutCareTaskMO.isTemplate))

        // Shows all tasks that are incomplete
        let isIncompletePredicate = NSPredicate(format: "%K == nil", #keyPath(SproutCareTaskMO.historyLog))

        // Shows all tasks that are completed today, including completed tasks
        let isCompletedToday: NSPredicate
        if doesShowCompletedTasks {
            let midnightToday = Calendar.current.startOfDay(for: Date())
            let midnightTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: midnightToday)!
             isCompletedToday = NSPredicate(format: "%K >= %@ && %K < %@", #keyPath(SproutCareTaskMO.displayDate), midnightToday as NSDate, #keyPath(SproutCareTaskMO.displayDate), midnightTomorrow as NSDate)
        } else {
            isCompletedToday = NSPredicate.init(value: false)
        }

        let taskTypePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [isIncompletePredicate, isCompletedToday])
        return NSCompoundPredicate(andPredicateWithSubpredicates: [isNotTemplatePredicate, taskTypePredicate])
    }
}

extension UpNextProvider: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateProperties()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        var newSnapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>

        let idsToReload = newSnapshot.itemIdentifiers.filter { identifier in
            guard let oldIndex = self.snapshot?.indexOfItem(identifier),
                  let newIndex = newSnapshot.indexOfItem(identifier),
                  oldIndex != newIndex
            else { return false }

            guard (try? controller.managedObjectContext.existingObject(with: identifier))?.isUpdated == true else {
                return false
            }

            return true
        }

        newSnapshot.reloadItems(idsToReload)
        self.snapshot = newSnapshot
    }
}


