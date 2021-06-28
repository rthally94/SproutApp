//
//  RelationshipKeyPathsObserver.swift
//  See https://www.avanderlee.com/swift/nsfetchedresultscontroller-observe-relationship-changes/
//
//  Created by Ryan Thally on 6/27/21.
//

import CoreData
import Foundation

public final class RelationshipKeyPathsObserver<ResultType: NSFetchRequestResult>: NSObject {
    private let keyPaths: Set<RelationshipKeyPath>
    private unowned let fetchedResultsController: RichFetchedResultsController<ResultType>

    private var updatedObjectIDs: Set<NSManagedObjectID> = []

    public init?(keyPaths: Set<String>, fetchedResultsController: RichFetchedResultsController<ResultType>) {
        guard !keyPaths.isEmpty else { return nil }

        let relationships = fetchedResultsController.fetchRequest.entity!.relationshipsByName
        self.keyPaths = Set(keyPaths.map { keyPath in
            return RelationshipKeyPath(keyPath: keyPath, relationships: relationships)
        })
        self.fetchedResultsController = fetchedResultsController

        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(contextDidChangeNotification(notification:)), name: .NSManagedObjectContextObjectsDidChange, object: fetchedResultsController.managedObjectContext)
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSaveNotificataion(notification:)), name: .NSManagedObjectContextWillSave, object: fetchedResultsController.managedObjectContext)
    }

    @objc private func contextDidChangeNotification(notification: NSNotification) {
        guard let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> else { return }
        guard let updatedObjectIDs = updatedObjects.updatedObjectIDs(for: keyPaths), !updatedObjectIDs.isEmpty else { return }
        self.updatedObjectIDs = self.updatedObjectIDs.union(updatedObjectIDs)
    }

    @objc private func contextDidSaveNotificataion(notification: NSNotification) {
        guard !updatedObjectIDs.isEmpty else { return }
        guard let fetchedObjects = fetchedResultsController.fetchedObjects as? [NSManagedObject], !fetchedObjects.isEmpty else { return }
        fetchedObjects.forEach { object in
            guard updatedObjectIDs.contains(object.objectID) else { return }
            fetchedResultsController.managedObjectContext.refresh(object, mergeChanges: true)
        }
        updatedObjectIDs.removeAll()
    }
}

private extension Set where Element: NSManagedObject {
    func updatedObjectIDs(for keyPaths: Set<RelationshipKeyPath>) -> Set<NSManagedObjectID>? {
        var objectIDs: Set<NSManagedObjectID> = []
        forEach { object in
            guard let changedRelationshipKeyPath = object.changedKeyPath(from: keyPaths) else { return }
            let value = object.value(forKey: changedRelationshipKeyPath.inverseRelationshipKeyPath)
            if let toManyObjects = value as? Set<NSManagedObject> {
                toManyObjects.forEach {
                    objectIDs.insert($0.objectID)
                }
            } else if let toOneObject = value as? NSManagedObject {
                objectIDs.insert(toOneObject.objectID)
            } else {
                assertionFailure("Invalid relationship observed for keyPath: \(changedRelationshipKeyPath)")
                return
            }
        }

        return objectIDs
    }
}

private extension NSManagedObject {
    func changedKeyPath(from keyPaths: Set<RelationshipKeyPath>) -> RelationshipKeyPath? {
        return keyPaths.first { keyPath -> Bool in
            guard keyPath.destinationEntityName == entity.name! || keyPath.destinationEntityName == entity.superentity?.name else { return false }
            return changedValues().keys.contains(keyPath.destinationPropertyName)
        }
    }
}
