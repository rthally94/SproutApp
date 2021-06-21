//
//  SproutPlantMO+SwiftProperties.swift
//  Sprout
//
//  Created by Ryan Thally on 6/21/21.
//

import SproutKit
import UIKit


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

    var plantTemplate: SproutPlantTemplate? {
        get {
            if let existing = SproutPlantTemplate.allTypes.first(where: { template in
                template.scientificName == scientificName
                    && template.commonName == commonName
            }) {
                return existing
            } else if let scientificName = scientificName, let commonName = commonName {
                return SproutPlantTemplate(scientificName: scientificName, commonName: commonName)
            } else {
                return nil
            }
        }
        set {
            scientificName = newValue?.scientificName
            commonName = newValue?.commonName
        }
    }
}
