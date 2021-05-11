//
//  CareInfoType.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/30/21.
//

import CoreData
import UIKit

public class CareCategory: NSManagedObject {
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

    static func Icon(inContext context: NSManagedObjectContext, forType type: CareCategory.TaskTypeName) -> SproutIcon {
        switch type {
        case .wateringTaskType:
            let icon = SproutIcon(context: context)
            icon.symbolName = "drop.fill"
            icon.color = UIColor.systemBlue
            return icon
        }
    }

    static func fetchOrCreateCategory(withName name: CareCategory.TaskTypeName, inContext context: NSManagedObjectContext) throws -> CareCategory {
        let request: NSFetchRequest<CareCategory> = CareCategory.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(CareCategory.name), name.rawValue)

        if let type = try context.fetch(request).first {
            return type
        }

        let newType = CareCategory(context: context)
        newType.id = UUID()
        newType.creationDate = Date()
        newType.name = name.description
        newType.icon = CareCategory.Icon(inContext: context, forType: name)

        return newType
    }
}
