//
//  SproutCareTaskMO+FetchReqests.swift
//  
//
//  Created by Ryan Thally on 6/25/21.
//

import CoreData
import Foundation

extension SproutCareTaskMO {
    enum SortDescriptors {
        static let sortByCreationDate = NSSortDescriptor(keyPath: \SproutCareTaskMO.creationDate, ascending: true)
        static let sortByLastModifiedDate = NSSortDescriptor(keyPath: \SproutCareTaskMO.lastModifiedDate, ascending: true)

        static let sortByDueDate = NSSortDescriptor(keyPath: \SproutCareTaskMO.dueDate, ascending: true)
    }

    enum Predicates {
        static func statusPredicate(for markStatus: SproutMarkStatus) -> NSPredicate {
            return NSPredicate(format: "%K == &@", #keyPath(SproutCareTaskMO.status), markStatus.rawValue)
        }
    }

    static func dueTasksFetchRequest() -> NSFetchRequest<SproutCareTaskMO> {
        let request: NSFetchRequest<SproutCareTaskMO> = SproutCareTaskMO.fetchRequest()
        request.sortDescriptors = [SortDescriptors.sortByDueDate]
        request.predicate = Predicates.statusPredicate(for: .due)

        return request
    }
}
