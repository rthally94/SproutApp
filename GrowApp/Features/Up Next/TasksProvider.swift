//
//  TasksProvider.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/29/21.
//

import CoreData
import UIKit

class TasksProvider: NSObject {
    typealias Section = String
    typealias Item = NSManagedObjectID

    let moc: NSManagedObjectContext
    fileprivate let fetchedResultsController: NSFetchedResultsController<SproutReminder>

    @Published var snapshot: NSDiffableDataSourceSnapshot<Section, Item>?

    init(managedObjectContext: NSManagedObjectContext) {
        self.moc = managedObjectContext

        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)

        let request: NSFetchRequest<SproutReminder> = SproutReminder.allRemindersFetchRequest(startingOn: nil, endingBefore: tomorrow)
        let sortByCareInfoCategoryName = NSSortDescriptor(keyPath: \SproutReminder.careInfo?.careCategory?.name, ascending: true)
        let sortByPlantName = NSSortDescriptor(keyPath: \SproutReminder.careInfo?.plant?.name, ascending: true)
        request.sortDescriptors = [sortByCareInfoCategoryName, sortByPlantName]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: #keyPath(SproutReminder.careInfo.careCategory.name), cacheName: nil)

        super.init()

        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
    }

    func object(at indexPath: IndexPath) -> SproutReminder {
        return fetchedResultsController.object(at: indexPath)
    }

    func object(withID id: NSManagedObjectID) -> AnyObject? {
        let task = moc.object(with: id)
        return task
    }
}

extension TasksProvider: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        self.snapshot = snapshot as NSDiffableDataSourceSnapshot<Section, Item>
    }
}


