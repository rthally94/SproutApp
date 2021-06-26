//
//  SproutCareInformationMO.swift
//  Sprout
//
//  Created by Ryan Thally on 6/16/21.
//

import CoreData
import UIKit

public final class SproutCareInformationMO: NSManagedObject {
    override public func awakeFromInsert() {
        super.awakeFromInsert()

        setPrimitiveValue(UUID().uuidString, forKey: #keyPath(SproutPlantMO.identifier))
        setPrimitiveValue(Date(), forKey: #keyPath(SproutPlantMO.creationDate))
        setPrimitiveValue(Date(), forKey: #keyPath(SproutPlantMO.lastModifiedDate))
    }

    override public func willSave() {
        super.willSave()

        setPrimitiveValue(Date(), forKey: #keyPath(SproutPlantMO.lastModifiedDate))
    }
}

// Convenience methods for creating care information
public extension SproutCareInformationMO {
    @discardableResult private static func insertNewCareInformation(of type: SproutCareType, into context: NSManagedObjectContext) -> SproutCareInformationMO {
        let newInfo = SproutCareInformationMO(context: context)
        newInfo.type = type.rawValue
        return newInfo
    }

    static func fetchOrInsertCareInformation(of type: SproutCareType, for plant: SproutPlantMO? = nil, in context: NSManagedObjectContext) -> SproutCareInformationMO {
        if let plant = plant {
            let request = Self.latestCareInformationFetchRequest(of: type, for: plant)
            if let info = try? context.fetch(request).first {
                return info
            }

            let newInfo = Self.insertNewCareInformation(of: type, into: context)
            newInfo.plant = plant
            return newInfo
        } else {
            return Self.insertNewCareInformation(of: type, into: context)
        }
    }
}
