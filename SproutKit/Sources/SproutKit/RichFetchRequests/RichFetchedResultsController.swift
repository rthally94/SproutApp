//
//  RichFetchedResultsController.swift
//  See https://www.avanderlee.com/swift/nsfetchedresultscontroller-observe-relationship-changes/
//
//  Created by Ryan Thally on 6/27/21.
//

import CoreData
import Foundation

public class RichFetchedResultsController<ResultType: NSFetchRequestResult>: NSFetchedResultsController<NSFetchRequestResult> {
    private var relationshipKeyPathObserver: RelationshipKeyPathsObserver<ResultType>?

    public init(fetchRequest: RichFetchRequest<ResultType>, managedObjectContext: NSManagedObjectContext, sectionNameKeyPath: String?, cacheName name: String?) {
        super.init(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: name)
        relationshipKeyPathObserver = RelationshipKeyPathsObserver<ResultType>(keyPaths: fetchRequest.relationshipKeyPathsForRefreshing, fetchedResultsController: self)
    }
}
