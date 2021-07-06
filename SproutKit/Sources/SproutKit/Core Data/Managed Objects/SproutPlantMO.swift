//
//  SproutPlantMO-v102.swift
//  Sprout
//
//  Created by Ryan Thally on 6/15/21.
//

import CoreData
import UIKit

public final class SproutPlantMO: NSManagedObject {
    override public func awakeFromInsert() {
        super.awakeFromInsert()

        setPrimitiveValue(UUID().uuidString, forKey: #keyPath(SproutPlantMO.identifier))
        setPrimitiveValue(Date(), forKey: #keyPath(SproutPlantMO.creationDate))
        setPrimitiveValue(Date(), forKey: #keyPath(SproutPlantMO.lastModifiedDate))
    }

    public override func awakeFromFetch() {
        super.awakeFromFetch()

        // Populate thumbnail
        let fullImage = getImage(preferredSize: .full)
        thumbnailImageData = fullImage?.orientedUp()?.makeThumbnail()?.pngData()
    }

    override public func willSave() {
        super.willSave()

        setPrimitiveValue(Date(), forKey: #keyPath(SproutPlantMO.lastModifiedDate))
    }
}


// Convenience methods for creating plants
public extension SproutPlantMO {
    @discardableResult static func insertNewPlant(into context: NSManagedObjectContext) -> SproutPlantMO {
        let plant = SproutPlantMO(context: context)
        return plant
    }

    @discardableResult static func insertNewPlant(using template: SproutPlantTemplate, into context: NSManagedObjectContext) -> SproutPlantMO {
        let newPlant = insertNewPlant(into: context)

        newPlant.scientificName = template.scientificName
        newPlant.commonName = template.commonName

        return newPlant
    }
}
