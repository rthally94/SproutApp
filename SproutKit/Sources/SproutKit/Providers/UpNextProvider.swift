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
    fileprivate var fetchedResultsController: RichFetchedResultsController<SproutCareTaskMO>!

    @Published public var snapshot: NSDiffableDataSourceSnapshot<String, NSManagedObjectID>?

    public var doesShowCompletedTasks: Bool = false {
        didSet {
            fetchedResultsController = makeTasksFRC()
            try? fetchedResultsController.performFetch()
        }
    }

    public init(managedObjectContext: NSManagedObjectContext) {
        self.moc = managedObjectContext
        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(persistentStoreCoordinatorStoresDidChangeNotification(notification:)), name: .NSPersistentStoreCoordinatorStoresDidChange, object: nil)

        restartFRC()
    }


    public func object(at indexPath: IndexPath) -> SproutCareTaskMO? {
        return fetchedResultsController.object(at: indexPath) as? SproutCareTaskMO
    }

    public func task(withID id: NSManagedObjectID) -> SproutCareTaskMO? {
        return try? moc.existingObject(with: id) as? SproutCareTaskMO
    }

    public func plant(withID id: NSManagedObjectID) -> SproutPlantMO? {
        return try? moc.existingObject(with: id) as? SproutPlantMO
    }

    @objc private func persistentStoreCoordinatorStoresDidChangeNotification(notification: NSNotification) {
        if let addedStores = notification.userInfo?[NSAddedPersistentStoresKey] as? [NSPersistentStore], addedStores.contains(where: { store in
            store.url?.absoluteString.contains("SproutCoreDataModel") == true
        }) {
            print("SproutCoreDataModelAdded. Restarting Provider")
            restartFRC()
        }
    }

    private func restartFRC() {
        fetchedResultsController = makeTasksFRC()
        try! fetchedResultsController.performFetch()
    }

    private func makeTasksFRC() -> RichFetchedResultsController<SproutCareTaskMO> {
        let request = SproutCareTaskMO.upNextFetchRequest(includesCompleted: doesShowCompletedTasks)
        let controller: RichFetchedResultsController<SproutCareTaskMO> = RichFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: #keyPath(SproutCareTaskMO.statusDate), cacheName: nil)
        controller.delegate = self
        return controller
    }
}

extension UpNextProvider: NSFetchedResultsControllerDelegate {
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        self.snapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
    }
}

