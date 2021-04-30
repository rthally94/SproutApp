//
//  GHTaskType.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/30/21.
//

import CoreData

public class GHTaskType: NSManagedObject {
    static let WateringTaskType = "watering"

    static func fetchOrCreateTaskType(withName name: String, inContext context: NSManagedObjectContext) throws -> GHTaskType {
        let request: NSFetchRequest<GHTaskType> = GHTaskType.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(GHTaskType.name), name)

        if let type = try context.fetch(request).first {
            return type
        }

        let newType = GHTaskType(context: context)
        newType.name = name

        return newType
    }
}
