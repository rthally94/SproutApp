//
//  RemindersProvider.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/21/21.
//

import CoreData
import Combine
import Foundation

class ReminderNotificationProvider: NSObject {
    let moc: NSManagedObjectContext
    
    fileprivate let fetchedResultsController: NSFetchedResultsController<SproutReminder>
    
    @Published var data: [Date: [SproutReminder]]?
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.moc = managedObjectContext
        
        let request: NSFetchRequest<SproutReminder> = SproutReminder.incompleteRemindersFetchRequest(startingOn: nil, endingBefore: nil)
        let incompletePredicate = request.predicate
        let isScheduledPredicate = NSPredicate(format: "%K != nil", #keyPath(SproutReminder.scheduledDate))
        let predicates = [incompletePredicate, isScheduledPredicate].compactMap { $0 }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        
        super.init()
        
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
        updateData()
    }
    
    func updateData() {
        let reminders = fetchedResultsController.fetchedObjects
        let midnightToday = Calendar.current.startOfDay(for: Date())
        data = reminders?.reduce(into: [Date: [SproutReminder]](), { result, reminder in
            if let scheduledDate = reminder.scheduledDate {
                // Any tasks that scheduled care before today, will be grouped in today
                let date = Calendar.current.startOfDay(for: scheduledDate < midnightToday ? midnightToday : scheduledDate)
                result[date, default: []].append(reminder)
            }
        })
    }
}

extension ReminderNotificationProvider: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateData()
    }
}
