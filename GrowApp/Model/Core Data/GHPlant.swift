//
//  GHPlant.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/30/21.
//

import CoreData
import UIKit

public class GHPlant: NSManagedObject {
    private static let DefaultPlantName = "My New Plant"

    static func createDefaultPlant(inContext context: NSManagedObjectContext) throws -> GHPlant {
        let newPlant = GHPlant(context: context)
        newPlant.id = UUID()

//        let defaultPlantsCountRequest: NSFetchRequest<GHPlant> = GHPlant.fetchRequest()
//        defaultPlantsCountRequest.predicate = NSPredicate(format: "%K beginswith %@", #keyPath(GHPlant.name), GHPlant.DefaultPlantName)
//        let defaultPlantCount = (try? context.count(for: defaultPlantsCountRequest)) ?? 0
//        newPlant.name = GHPlant.DefaultPlantName + " \(defaultPlantCount+1)"
        newPlant.creationDate = Date()

        newPlant.icon = SproutIcon.createIconWithImage(UIImage(named: "SamplePlantImage"), inContext: context)

        return newPlant
    }

    var hasUpdates: Bool {
        return isUpdated
            || icon?.isUpdated == true
            || type?.isUpdated == true
            || tasks.contains(where: { $0.isUpdated })
    }
}

extension GHPlant {
    func isMetadataValid() -> Bool {
        id != nil
        && creationDate != nil
    }

    func isNameValid() -> Bool {
        guard let name = name else { return false }
        return !name.isEmpty
    }

    func isIconValid() -> Bool {
        guard let icon = icon else { return false }
        // TODO: Check validity of icon
        return true
    }

    func isTypeValid() -> Bool {
        guard let type = type else { return false }
        // TODO: Check validity of type
        return true
    }
}
