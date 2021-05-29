//
//  PlantsProvider.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/1/21.
//

import CoreData
import UIKit

class PlantsProvider: NSObject {
    typealias Section = String
    typealias Item = NSManagedObjectID
    
    let moc: NSManagedObjectContext
    fileprivate let fetchedResultsController: NSFetchedResultsController<SproutPlant>
    
    @Published var snapshot: NSDiffableDataSourceSnapshot<Section, Item>?
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.moc = managedObjectContext
        
        let request: NSFetchRequest<SproutPlant> = SproutPlant.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SproutPlant.name, ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        
        super.init()
        
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
    }
    
    func object(at indexPath: IndexPath) -> SproutPlant {
        return fetchedResultsController.object(at: indexPath)
    }

    func object(withID id: NSManagedObjectID) -> SproutPlant? {
        return moc.object(with: id) as? SproutPlant
    }

    func reload() {
        try! fetchedResultsController.performFetch()
    }
}

extension PlantsProvider: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        self.snapshot = snapshot as NSDiffableDataSourceSnapshot<Section, Item>
    }
}
