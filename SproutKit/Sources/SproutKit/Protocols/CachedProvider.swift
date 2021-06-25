//
//  File.swift
//  
//
//  Created by Ryan Thally on 6/25/21.
//

import CoreData
import Foundation

protocol CachedProvider: AnyObject {
    associatedtype ManagedObjectType: NSManagedObject

    var fetchedIDs: [NSManagedObjectID] { get set }
    var objects: [NSManagedObjectID: ManagedObjectType] { get set }
    var persistentContainer: NSPersistentContainer { get }

    var numberOfItems: Int { get }

    init(persistentContainer: NSPersistentContainer)

    func fetch(_ completion: @escaping () -> Void)
    func object(at index: Int) -> ManagedObjectType?
}

extension CachedProvider {
    var numberOfItems: Int { fetchedIDs.count }

    func fetch(_ completion: @escaping () -> Void) {
        persistentContainer.performBackgroundTask { [weak self] context in
            let request = NSFetchRequest<NSManagedObjectID>(entityName: ManagedObjectType.entityName)
            request.resultType = .managedObjectIDResultType

            self?.fetchedIDs = (try? context.fetch(request)) ?? []
            completion()
        }
    }

    func object(at index: Int) -> ManagedObjectType? {
        let id = fetchedIDs[index]

        // If object is already in cache, return the cached object
        if let object = objects[id] {
            return object
        }

        // If object is not in cache, try to get the object form the context
        let viewContext = persistentContainer.viewContext
        if let object = try? viewContext.existingObject(with: id) as? ManagedObjectType {
            objects[id] = object
            return object
        }

        return nil
    }
}
