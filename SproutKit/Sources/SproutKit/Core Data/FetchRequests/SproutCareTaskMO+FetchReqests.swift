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

        static func dueDatePredicate(dueDate: Date) -> NSPredicate {
            let midnightStartDate = Calendar.current.startOfDay(for: dueDate)
            let midnightAfterStartDate = Calendar.current.date(byAdding: .day, value: 1, to: midnightStartDate)!
            return NSPredicate(format: "%K >= %@ AND %K < %@", #keyPath(SproutCareTaskMO.dueDate), midnightStartDate as NSDate, #keyPath(SproutCareTaskMO.dueDate), midnightAfterStartDate as NSDate)
        }
    }

    static func dueTasksFetchRequest(dueOn dueDate: Date? = nil) -> NSFetchRequest<SproutCareTaskMO> {
        let request: NSFetchRequest<SproutCareTaskMO> = SproutCareTaskMO.fetchRequest()
        request.sortDescriptors = [SortDescriptors.sortByDueDate]

        let dueDatePredicate = dueDate != nil ? Predicates.dueDatePredicate(dueDate: dueDate!) : NSPredicate(value: true)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            Predicates.statusPredicate(for: .due),
            dueDatePredicate
        ])

        return request
    }

    static func upNextFetchRequest(includesCompleted: Bool = false) -> NSFetchRequest<SproutCareTaskMO> {
        let request: NSFetchRequest<SproutCareTaskMO> = SproutCareTaskMO.fetchRequest()
        let sortByDisplayDate = NSSortDescriptor(keyPath: \SproutCareTaskMO.statusDate, ascending: true)
        let sortByTaskType = NSSortDescriptor(keyPath: \SproutCareTaskMO.careInformation?.type, ascending: true)
        let sortByPlantName = NSSortDescriptor(keyPath: \SproutCareTaskMO.plant?.nickname, ascending: true)
        request.sortDescriptors = [sortByDisplayDate, sortByTaskType, sortByPlantName]

        // Shows all tasks that are incomplete
        let isDuePredicate = NSPredicate(format: "%K == %@", #keyPath(SproutCareTaskMO.status), SproutMarkStatus.due.rawValue)
        let isLatePredicate = NSPredicate(format: "%K == %@", #keyPath(SproutCareTaskMO.status), SproutMarkStatus.late.rawValue)
        let isIncompletePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [isDuePredicate, isLatePredicate])

        // Shows all tasks that are completed today, including completed tasks
        let isCompletedToday: NSPredicate
        if includesCompleted {
            let midnightToday = Calendar.current.startOfDay(for: Date())
            let midnightTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: midnightToday)!
             isCompletedToday = NSPredicate(format: "%K >= %@ && %K < %@", #keyPath(SproutCareTaskMO.statusDate), midnightToday as NSDate, #keyPath(SproutCareTaskMO.statusDate), midnightTomorrow as NSDate)
        } else {
            isCompletedToday = NSPredicate.init(value: false)
        }

        let upNextPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [isIncompletePredicate, isCompletedToday])
        request.predicate = upNextPredicate

        return request
    }

    static func remindersFetchRequest() -> NSFetchRequest<SproutCareTaskMO> {
        let request = SproutCareTaskMO.fetchRequest

        let sortByStatusDate = NSSortDescriptor(keyPath: \SproutCareTaskMO.statusDate, ascending: true)
        let sortByPlantNickname = NSSortDescriptor(keyPath: \SproutCareTaskMO.plant?.nickname, ascending: true)
        let sortByPlantCommonName = NSSortDescriptor(keyPath: \SproutCareTaskMO.plant?.commonName, ascending: true)

        request.sortDescriptors = [
            sortByStatusDate,
            sortByPlantNickname,
            sortByPlantCommonName
        ]

        let isDuePredicate = NSPredicate(format: "%K == %@", #keyPath(SproutCareTaskMO.status), SproutMarkStatus.due.rawValue)
        let isLatePredicate = NSPredicate(format: "%K == %@", #keyPath(SproutCareTaskMO.status), SproutMarkStatus.late.rawValue)
        let isCareNeededPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [isDuePredicate, isLatePredicate])

        let isScheduledPredicate = NSPredicate(format: "%K == true && %K != nil", #keyPath(SproutCareTaskMO.hasSchedule), #keyPath(SproutCareTaskMO.dueDate))

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [isCareNeededPredicate, isScheduledPredicate])

        return request
    }
}
