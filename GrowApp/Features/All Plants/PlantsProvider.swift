//
//  PlantsProvider.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/1/21.
//

import CoreData
import UIKit

class PlantsProvider: NSObject {
    typealias Section = Int
    typealias Item = NSManagedObjectID
    
    let moc: NSManagedObjectContext
    fileprivate let fetchedResultsController: NSFetchedResultsController<GHPlant>
    
    @Published var snapshot: NSDiffableDataSourceSnapshot<Section, Item>?
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.moc = managedObjectContext
        
        let request: NSFetchRequest<GHPlant> = GHPlant.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \GHPlant.name, ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        
        super.init()
        
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
    }
    
    func object(at indexPath: IndexPath) -> GHPlant {
        return fetchedResultsController.object(at: indexPath)
    }

    func reload() {
        try! fetchedResultsController.performFetch()
    }
}

extension PlantsProvider: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        var newSnapshot = snapshot as NSDiffableDataSourceSnapshot<Section, Item>
        let idsToReload = newSnapshot.itemIdentifiers.filter {identifier in
            guard let oldIndex = self.snapshot?.indexOfItem(identifier), let newIndex = newSnapshot.indexOfItem(identifier), oldIndex == newIndex else { return false }
            
            guard (try? controller.managedObjectContext.existingObject(with: identifier))?.isUpdated == true else { return false }
            
            return true
        }
        
        newSnapshot.reloadItems(idsToReload)
        self.snapshot = newSnapshot
    }
}
