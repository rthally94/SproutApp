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
    
    fileprivate let fetchedResultsController: NSFetchedResultsController<SproutCareTaskMO>
    
    @Published var data: [Date: [SproutCareTaskMO]]?
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.moc = managedObjectContext
        
        let request: NSFetchRequest<SproutCareTaskMO> = SproutCareTaskMO.fetchRequest()

        let sortByDueDate = NSSortDescriptor(keyPath: \SproutCareTaskMO.dueDate, ascending: true)
        let sortByPlantNickname = NSSortDescriptor(keyPath: \SproutCareTaskMO.plant?.nickname, ascending: true)
        let sortByPlantCommonName = NSSortDescriptor(keyPath: \SproutCareTaskMO.plant?.commonName, ascending: true)

        request.sortDescriptors = [
            sortByDueDate,
            sortByPlantNickname,
            sortByPlantCommonName
        ]

        let isNotTemplatePredicate = NSPredicate(format: "%K == false", #keyPath(SproutCareTaskMO.isTemplate))
        let isNotCompletedPredicate = NSPredicate(format: "%K == nil", #keyPath(SproutCareTaskMO.historyLog))
        let isScheduledPredicate = NSPredicate(format: "%K == true && %K != nil", #keyPath(SproutCareTaskMO.hasSchedule), #keyPath(SproutCareTaskMO.dueDate))
        let predicates = [isNotTemplatePredicate, isNotCompletedPredicate, isScheduledPredicate].compactMap { $0 }
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
        data = reminders?.reduce(into: [Date: [SproutCareTaskMO]](), { result, task in
            if let scheduledDate = task.dueDate {
                // Any tasks that scheduled care before today, will be grouped in today
                let date = Calendar.current.startOfDay(for: scheduledDate < midnightToday ? midnightToday : scheduledDate)
                result[date, default: []].append(task)
            }
        })
    }
}

extension ReminderNotificationProvider: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateData()
    }
}
