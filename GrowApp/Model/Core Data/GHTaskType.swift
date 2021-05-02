//
//  GHTaskType.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/30/21.
//

import CoreData
import UIKit

public class GHTaskType: NSManagedObject {
    enum TaskTypeName: String, CaseIterable, CustomStringConvertible {
        case wateringTaskType

        var description: String {
            switch self {
                case .wateringTaskType: return "Watering"
            }
        }
    }

    static var allTypes = [
        TaskTypeName.wateringTaskType
    ]

    static func Icon(inContext context: NSManagedObjectContext, forType type: GHTaskType.TaskTypeName) -> GHIcon {
        switch type {
        case .wateringTaskType:
            let icon = GHIcon(context: context)
            icon.symbolName = "drop.fill"
            icon.color = UIColor.systemBlue
            return icon
        }
    }

    static func fetchOrCreateTaskType(withName name: GHTaskType.TaskTypeName, inContext context: NSManagedObjectContext) throws -> GHTaskType {
        let request: NSFetchRequest<GHTaskType> = GHTaskType.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(GHTaskType.name), name.rawValue)

        if let type = try context.fetch(request).first {
            return type
        }

        let newType = GHTaskType(context: context)
        newType.name = name.description
        newType.icon = GHTaskType.Icon(inContext: context, forType: name)

        return newType
    }
}
