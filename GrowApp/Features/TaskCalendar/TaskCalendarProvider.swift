//
//  TaskCalendarFetchedResultsController.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/31/21.
//

import UIKit
import CoreData

class TaskCalendarProvider: NSObject {
    let moc: NSManagedObjectContext
    fileprivate let fetchedResultsController: NSFetchedResultsController<CareInfo>
    
    @Published var snapshot: NSDiffableDataSourceSnapshot<String, NSManagedObjectID>?
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.moc = managedObjectContext
        
        let request: NSFetchRequest<CareInfo> = CareInfo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CareInfo.plant?.name, ascending: true)]
        
        // TODO: Add support to fetch for a specific day
//        let intervalPredicate = CareInfo.isDateInIntervalPredicate(Date())
//        print(intervalPredicate.predicateFormat)
//        request.predicate = NSPredicate(format: "SUBQUERY(interval, $x, \(intervalPredicate.predicateFormat)).@count > 0")
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        
        super.init()
        
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
    }
    
    func object(at indexPath: IndexPath) -> CareInfo {
        return fetchedResultsController.object(at: indexPath)
    }
}

extension TaskCalendarProvider: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        var newSnapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
        let idsToReload = newSnapshot.itemIdentifiers.filter({ identifier in
            guard let oldIndex = self.snapshot?.indexOfItem(identifier), let newIndex = newSnapshot.indexOfItem(identifier), oldIndex == newIndex else { return false}
            
            guard (try? controller.managedObjectContext.existingObject(with: identifier))?.isUpdated == true else { return false }
            
            return true
        })
        
        newSnapshot.reloadItems(idsToReload)
        
        self.snapshot = newSnapshot
    }
}
