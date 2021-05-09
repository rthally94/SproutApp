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
    fileprivate let fetchedResultsController: NSFetchedResultsController<GHTask>

    @Published var snapshot: NSDiffableDataSourceSnapshot<Section, Item>?

    init(managedObjectContext: NSManagedObjectContext) {
        self.moc = managedObjectContext

        let request: NSFetchRequest<GHTask> = GHTask.fetchRequest()
        let sortByNextTaskDate = NSSortDescriptor(keyPath: \GHTask.nextCareDate, ascending: true)
        let sortByTaskName = NSSortDescriptor(keyPath: \GHTask.taskType?.name, ascending: true)
        let sortByPlantName = NSSortDescriptor(keyPath: \GHTask.plant?.name, ascending: true)
        request.sortDescriptors = [sortByNextTaskDate, sortByTaskName, sortByPlantName]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: #keyPath(GHTask.nextCareDate), cacheName: nil)

        super.init()

        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
    }

    func object(at indexPath: IndexPath) -> GHTask {
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


