//
//  TasksProvider.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/29/21.
//

import CoreData
import UIKit

final public class UpNextProvider: NSObject {
    public typealias Section = String
    public typealias Item = NSManagedObjectID
    public typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    private let stringToDateFormatter = Utility.ISODateFormatter

    var moc: NSManagedObjectContext {
        fetchedResultsController.managedObjectContext
    }

    fileprivate var fetchedResultsController: RichFetchedResultsController<SproutCareTaskMO>!

    @Published public var snapshot: Snapshot?

    public var completedTaskDateMarker: Date? {
        didSet {
            fetchedResultsController = makeTasksFRC(context: moc)
            try! fetchedResultsController.performFetch()
        }
    }

    public init(storageProvider: StorageProvider) {
        super.init()

        fetchedResultsController = makeTasksFRC(context: storageProvider.persistentContainer.viewContext)
        try! fetchedResultsController.performFetch()

        NotificationCenter.default.addObserver(self, selector: #selector(persistentStoreCoordinatorStoresDidChangeNotification(notification:)), name: .NSPersistentStoreCoordinatorStoresDidChange, object: nil)
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
        fetchedResultsController = makeTasksFRC(context: moc)
        try! fetchedResultsController.performFetch()
    }

    private func makeTasksFRC(context: NSManagedObjectContext) -> RichFetchedResultsController<SproutCareTaskMO> {
        let request = SproutCareTaskMO.upNextFetchRequest(includesCompletedAfter: completedTaskDateMarker)
        let controller: RichFetchedResultsController<SproutCareTaskMO> = RichFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(SproutCareTaskMO.upNextGroupingDate), cacheName: nil)
        controller.delegate = self
        return controller
    }
}

extension UpNextProvider: NSFetchedResultsControllerDelegate {
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        var newSnapshot = snapshot as Snapshot

        let idsToReload = newSnapshot.itemIdentifiers.filter { identifier in
            guard let oldIndex = self.snapshot?.indexOfItem(identifier),
                  let newIndex = newSnapshot.indexOfItem(identifier)
            else { return false }

            let sameIndex = newIndex == oldIndex

            let task = self.task(withID: identifier)
            let plant = task?.plant
            guard (task?.isUpdated == true || plant?.isUpdated == true) && sameIndex else { return false }

            return true
        }

        newSnapshot.reloadItems(idsToReload)
        self.snapshot = newSnapshot
    }
}

