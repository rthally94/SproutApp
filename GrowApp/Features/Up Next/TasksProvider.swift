//
//  TasksProvider.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/29/21.
//

import CoreData
import UIKit

struct UpNextSection<Item>: Hashable where Item: Hashable {
    var headerTitle: String
    var items: [Item]
}

class TasksProvider: NSObject {
    typealias Item = NSManagedObjectID
    typealias Section = String

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
}

extension TasksProvider: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        var newSnapshot = snapshot as NSDiffableDataSourceSnapshot<Section, Item>
        let idsToReload = newSnapshot.itemIdentifiers.filter { identifier in
            guard let oldIndex = self.snapshot?.indexOfItem(identifier), let newIndex = newSnapshot.indexOfItem(identifier), oldIndex == newIndex else { return false }
            guard (try? controller.managedObjectContext.existingObject(with: identifier))?.isUpdated == true else { return false }
            return true
        }

        newSnapshot.reloadItems(idsToReload)
        self.snapshot = newSnapshot
    }
}


