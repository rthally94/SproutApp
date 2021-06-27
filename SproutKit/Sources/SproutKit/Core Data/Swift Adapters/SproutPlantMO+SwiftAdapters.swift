//
//  SproutPlantMO+SwiftAdapters.swift
//  
//
//  Created by Ryan Thally on 6/26/21.
//

import UIKit

public extension SproutPlantMO {
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

    func asyncLoadImage(completion: @escaping ((UIImage?) -> Void)) {
        DispatchQueue.global().async { [weak self] in
            let image = self?.getImage(preferredSize: .full)
            DispatchQueue.main.async {
                completion(image)
            }
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
