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
    fileprivate let fetchedResultsController: NSFetchedResultsController<CareInfo>

    @Published var snapshot: NSDiffableDataSourceSnapshot<Section, Item>?

    init(managedObjectContext: NSManagedObjectContext) {
        self.moc = managedObjectContext

        let request: NSFetchRequest<CareInfo> = CareInfo.fetchRequest()
        let sortByNextTaskDate = NSSortDescriptor(keyPath: \CareInfo.nextCareDate, ascending: true)
        let sortByTaskName = NSSortDescriptor(keyPath: \CareInfo.careCategory?.name, ascending: true)
        let sortByPlantName = NSSortDescriptor(keyPath: \CareInfo.plant?.name, ascending: true)
        request.sortDescriptors = [sortByNextTaskDate, sortByTaskName, sortByPlantName]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: #keyPath(CareInfo.nextCareDate), cacheName: nil)

        super.init()

        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
    }

    func object(at indexPath: IndexPath) -> CareInfo {
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


