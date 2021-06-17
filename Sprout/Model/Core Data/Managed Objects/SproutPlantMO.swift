//
//  SproutPlantMO-v102.swift
//  Sprout
//
//  Created by Ryan Thally on 6/15/21.
//

import CoreData
import UIKit

final class SproutPlantMO: NSManagedObject {
    override func awakeFromInsert() {
        super.awakeFromInsert()

        setPrimitiveValue(UUID().uuidString, forKey: #keyPath(SproutPlantMO.id))
        setPrimitiveValue(Date(), forKey: #keyPath(SproutPlantMO.creationDate))
        setPrimitiveValue(Date(), forKey: #keyPath(SproutPlantMO.lastModifiedDate))
    }

    override func willSave() {
        super.willSave()

        setPrimitiveValue(Date(), forKey: #keyPath(SproutPlantMO.lastModifiedDate))
    }
}

// Mapping to swift types
extension SproutPlantMO {
    var primaryDisplayName: String? {
        return nickname ?? commonName
    }

    var secondaryDisplayName: String? {
        if nickname != nil {
            return commonName
        } else if commonName != nil {
            return scientificName
        } else {
            return nil
        }
    }

    var icon: UIImage? {
        get {
            guard let data = fullImageData?.rawData else { return nil }
            return UIImage(data: data)
        }

        set {
            thumbnailImage = newValue?.orientedUp()?.makeThumbnail()?.pngData()

            if let moc = managedObjectContext, fullImageData == nil {
                fullImageData = SproutImageDataMO(context: moc)
            }

            fullImageData?.rawData = newValue?.orientedUp()?.pngData()
        }
    }

    var thumbnailIcon: UIImage? {
        get {
            guard let data = thumbnailImage else { return nil }
            return UIImage(data: data)
        }
        set {
            thumbnailImage = newValue?.orientedUp()?.makeThumbnail()?.pngData()
        }
    }

    var allCareInformation: [SproutCareInformationMO] {
        get {
            let infoSet = careInformation as? Set<SproutCareInformationMO>
            return infoSet?.sorted(by: { $0.type < $1.type } ) ?? []
        }
    }
}

// Convenience methods for creating plants
extension SproutPlantMO {
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

// Fetch Requests
extension SproutPlantMO {
    
}
