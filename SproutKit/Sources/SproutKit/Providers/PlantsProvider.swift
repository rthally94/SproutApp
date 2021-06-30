//
//  PlantsProvider.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/1/21.
//

import CoreData
import UIKit

public final class PlantsProvider: NSObject {
    public typealias Section = String
    public typealias Item = NSManagedObjectID
    
    var moc: NSManagedObjectContext {
        fetchedResultsController.managedObjectContext
    }

    fileprivate var fetchedResultsController: NSFetchedResultsController<SproutPlantMO>!
    
    @Published public var snapshot: NSDiffableDataSourceSnapshot<Section, Item>?

    public init(managedObjectContext: NSManagedObjectContext) {
        super.init()

        fetchedResultsController = makeFRC(context: managedObjectContext)
        try! fetchedResultsController.performFetch()

        NotificationCenter.default.addObserver(self, selector: #selector(persistentStoreCoordinatorStoresDidChangeNotification(notification:)), name: .NSPersistentStoreCoordinatorStoresDidChange, object: nil)
    }
    
    public func object(at indexPath: IndexPath) -> SproutPlantMO {
        return fetchedResultsController.object(at: indexPath)
    }

    public func object(withID id: NSManagedObjectID) -> SproutPlantMO? {
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
        fetchedResultsController = makeFRC(context: moc)
        try! fetchedResultsController.performFetch()
    }

    private func makeFRC(context: NSManagedObjectContext) -> NSFetchedResultsController<SproutPlantMO> {
        let request = SproutPlantMO.allPlantsFetchRequest()
        let frc = NSFetchedResultsController<SproutPlantMO>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }
}

extension PlantsProvider: NSFetchedResultsControllerDelegate {
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        var newSnapshot = snapshot as NSDiffableDataSourceSnapshot<Section, Item>

        let idsToReload = newSnapshot.itemIdentifiers.filter { identifier in
            guard let oldIndex = self.snapshot?.indexOfItem(identifier),
                  let newIndex = newSnapshot.indexOfItem(identifier),
                  oldIndex == newIndex
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
