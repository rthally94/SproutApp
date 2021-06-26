//
//  TasksProvider.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/29/21.
//

import CoreData
import UIKit

final public class UpNextProvider: NSObject {
    let moc: NSManagedObjectContext
    fileprivate var fetchedResultsController: NSFetchedResultsController<SproutCareTaskMO>!

    @Published public var snapshot: NSDiffableDataSourceSnapshot<String, NSManagedObjectID>?

    public var doesShowCompletedTasks: Bool = false {
        didSet {
            fetchedResultsController = makeFRC()
            try? fetchedResultsController.performFetch()
        }
    }

    public init(managedObjectContext: NSManagedObjectContext) {
        self.moc = managedObjectContext
        super.init()

        fetchedResultsController = makeFRC()
        try! fetchedResultsController.performFetch()
    }


    public func object(at indexPath: IndexPath) -> SproutCareTaskMO {
        return fetchedResultsController.object(at: indexPath)
    }

    public func task(withID id: NSManagedObjectID) -> SproutCareTaskMO? {
        return moc.object(with: id) as? SproutCareTaskMO
    }

    public func plant(withID id: NSManagedObjectID) -> SproutPlantMO? {
        return moc.object(with: id) as? SproutPlantMO
    }

    private func makeFRC() -> NSFetchedResultsController<SproutCareTaskMO> {
        let request = SproutCareTaskMO.upNextFetchRequest()
        let controller: NSFetchedResultsController<SproutCareTaskMO> = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: #keyPath(SproutCareTaskMO.statusDate), cacheName: nil)
        controller.delegate = self
        return controller
    }
}

extension UpNextProvider: NSFetchedResultsControllerDelegate {
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {

        DispatchQueue.global(qos: .userInteractive).async {
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

            DispatchQueue.main.async {
                self.snapshot = newSnapshot
            }
        }
    }
}

