//
//  File.swift
//  
//
//  Created by Ryan Thally on 6/25/21.
//

import CoreData
import Foundation

extension SproutCareInformationMO {
    enum SortDescriptors {
        static func sortByCreationDate(ascending: Bool = true) -> NSSortDescriptor {
            NSSortDescriptor(keyPath: \SproutCareInformationMO.creationDate, ascending: ascending)
        }

        static func sortByLastModifiedDate(ascending: Bool = true) -> NSSortDescriptor {
            NSSortDescriptor(keyPath: \SproutCareInformationMO.lastModifiedDate, ascending: ascending)
        }
    }

    enum Predicates {
        static func plantPredicate(for plant: SproutPlantMO) -> NSPredicate {
            NSPredicate(format: "%K == %@", #keyPath(SproutCareInformationMO.plant), plant)
        }

        static func careTypePredicate(for type: SproutCareType) -> NSPredicate {
            NSPredicate(format: "%K == %@", #keyPath(SproutCareInformationMO.type), type.rawValue)
        }
    }

    static func latestCareInformationFetchRequest(of type: SproutCareType, for plant: SproutPlantMO) -> NSFetchRequest<SproutCareInformationMO> {
        let request = SproutCareInformationMO.fetchRequest

        let plantPredicate = Predicates.plantPredicate(for: plant)
        let careTypePredicate = Predicates.careTypePredicate(for: type)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [plantPredicate, careTypePredicate])

        request.sortDescriptors = [SortDescriptors.sortByCreationDate(ascending: false)]

        request.fetchLimit = 1
        return request
    }
}
