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

    func object(withID id: NSManagedObjectID) -> GHPlant? {
        return moc.object(with: id) as? GHPlant
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
