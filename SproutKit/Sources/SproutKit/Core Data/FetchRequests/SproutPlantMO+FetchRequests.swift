//
//  SproutPlantMO+FetchRequests.swift
//  
//
//  Created by Ryan Thally on 6/25/21.
//

import CoreData
import Foundation

extension SproutPlantMO {
    enum SortDescriptors {
        static let sortByCreationDate = NSSortDescriptor(keyPath: \SproutPlantMO.creationDate, ascending: true)
        static let sortByLastModifiedDate = NSSortDescriptor(keyPath: \SproutPlantMO.lastModifiedDate, ascending: true)

        static let sortByNickname = NSSortDescriptor(keyPath: \SproutPlantMO.nickname, ascending: true)
        static let sortByCommonName = NSSortDescriptor(keyPath: \SproutPlantMO.commonName, ascending: true)
        static let sortByScientificName = NSSortDescriptor(keyPath: \SproutPlantMO.scientificName, ascending: true)
    }

    static func allPlantsFetchRequest() -> NSFetchRequest<SproutPlantMO> {
        let request: NSFetchRequest<SproutPlantMO> = SproutPlantMO.fetchRequest()
        request.sortDescriptors = [SortDescriptors.sortByNickname, SortDescriptors.sortByCreationDate]
        return request
    }
}
