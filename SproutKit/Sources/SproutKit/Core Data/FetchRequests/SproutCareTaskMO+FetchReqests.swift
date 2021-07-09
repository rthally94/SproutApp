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

        static func sortByDueDate(ascending: Bool) -> NSSortDescriptor {
            NSSortDescriptor(keyPath: \SproutCareTaskMO.dueDate, ascending: ascending)
        }

        static func sortByStatusDate(ascending: Bool) -> NSSortDescriptor {
            NSSortDescriptor(keyPath: \SproutCareTaskMO.statusDate, ascending: ascending)
        }

        static func sortByTaskType(ascending: Bool) -> NSSortDescriptor {
            NSSortDescriptor(keyPath: \SproutCareTaskMO.careInformation?.type, ascending: ascending)
        }

        static func sortByPlantNickname(ascending: Bool) -> NSSortDescriptor {
            NSSortDescriptor(keyPath: \SproutCareTaskMO.plant?.nickname, ascending: ascending)
        }

        static func sortByPlantCommonName(ascending: Bool) -> NSSortDescriptor {
            NSSortDescriptor(keyPath: \SproutCareTaskMO.plant?.commonName, ascending: ascending)
        }
    }

    enum Predicates {
        static func statusPredicate(for markStatus: SproutMarkStatus) -> NSPredicate {
            return NSPredicate(format: "%K == %@", #keyPath(SproutCareTaskMO.status), markStatus.rawValue)
        }

        static func careTypePredicate(for type: SproutCareType) -> NSPredicate {
            return NSPredicate(format: "%K == %@", #keyPath(SproutCareTaskMO.careInformation.type), type.rawValue)
        }

        static func plantPredicate(for plant: SproutPlantMO) -> NSPredicate {
            return NSPredicate(format: "%K == %@", #keyPath(SproutCareTaskMO.plant), plant)
        }

        static func isDonePredicate(on date: Date) -> NSPredicate {
            let midnightToday = Calendar.current.startOfDay(for: Date())
            let midnightTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: midnightToday)!

            let isDonePredicate = statusPredicate(for: .done)
            let isInSameDayAsDatePredicate = NSPredicate(format: "%K >= %@ && %K < %@", #keyPath(SproutCareTaskMO.statusDate), midnightToday as NSDate, #keyPath(SproutCareTaskMO.statusDate), midnightTomorrow as NSDate)
            return NSCompoundPredicate(andPredicateWithSubpredicates: [isDonePredicate, isInSameDayAsDatePredicate])
        }

        static func statusDatePredicate(startingOn startDate: Date? =  nil, endingBefore endDate: Date? = nil) -> NSPredicate {
            let startDatePredicate = startDate != nil ? NSPredicate(format: "%K >= %@", #keyPath(SproutCareTaskMO.statusDate), startDate! as NSDate) : NSPredicate(value: true)
            let endDatePredicate = endDate != nil ? NSPredicate(format: "%K < %@", #keyPath(SproutCareTaskMO.statusDate), endDate! as NSDate) : NSPredicate(value: true)

            return NSCompoundPredicate(andPredicateWithSubpredicates: [startDatePredicate, endDatePredicate])
        }

        static func dueDatePredicate(startingOn startDate: Date? = nil, endingBefore endDate: Date? = nil) -> NSPredicate {
            let startDatePredicate = startDate != nil ? NSPredicate(format: "%K >= %@", #keyPath(SproutCareTaskMO.dueDate), startDate! as NSDate) : NSPredicate(value: true)
            let endDatePredicate = endDate != nil ? NSPredicate(format: "%K < %@", #keyPath(SproutCareTaskMO.dueDate), endDate! as NSDate) : NSPredicate(value: true)

            return NSCompoundPredicate(andPredicateWithSubpredicates: [startDatePredicate, endDatePredicate])
        }

        static func dueDatePredicate(on dueDate: Date) -> NSPredicate {
            let midnightStartDate = Calendar.current.startOfDay(for: dueDate)
            let midnightAfterStartDate = Calendar.current.date(byAdding: .day, value: 1, to: midnightStartDate)!
            return dueDatePredicate(startingOn: midnightStartDate, endingBefore: midnightAfterStartDate)
        }

        static func isScheduledPredicate() -> NSPredicate {
            return NSPredicate(format: "%K != nil && %K != nil", #keyPath(SproutCareTaskMO.startDate), #keyPath(SproutCareTaskMO.dueDate))
        }
    }

    public static func dueTasksFetchRequest(dueOn dueDate: Date? = nil, plant: SproutPlantMO? = nil, careType: SproutCareType? = nil) -> NSFetchRequest<SproutCareTaskMO> {
        let request: NSFetchRequest<SproutCareTaskMO> = SproutCareTaskMO.fetchRequest()
        request.sortDescriptors = [SortDescriptors.sortByDueDate(ascending: true)]

        let dueDatePredicate = dueDate != nil ? Predicates.dueDatePredicate(on: dueDate!) : NSPredicate(value: true)
        let careTypePredicate = careType != nil ? Predicates.careTypePredicate(for: careType!) : NSPredicate(value: true)
        let plantPredicate = plant != nil ? Predicates.plantPredicate(for: plant!) : NSPredicate(value: true)

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            Predicates.statusPredicate(for: .due),
            dueDatePredicate,
            careTypePredicate,
            plantPredicate,
        ])

        return request
    }

    public static func upNextFetchRequest(includesCompletedAfter completionMarkDate: Date?) -> RichFetchRequest<SproutCareTaskMO> {
    let request = RichFetchRequest<SproutCareTaskMO>(entityName: SproutCareTaskMO.entityName)
        request.sortDescriptors = [
            SortDescriptors.sortByDueDate(ascending: true),
            SortDescriptors.sortByTaskType(ascending: true),
            SortDescriptors.sortByPlantNickname(ascending: true)
        ]

        // Shows all tasks that are incomplete
        let isDuePredicate = Predicates.statusPredicate(for: .due)

        let isDonePredicate = Predicates.statusPredicate(for: .done)
        let isDoneDateFilterPredicate = Predicates.statusDatePredicate(startingOn: completionMarkDate, endingBefore: nil)
        let isDoneAfterMarkDatePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [isDonePredicate, isDoneDateFilterPredicate])

        // Shows all tasks that are completed today, including completed tasks
        let upNextPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [isDuePredicate, isDoneAfterMarkDatePredicate])
        request.predicate = upNextPredicate

        request.relationshipKeyPathsForRefreshing = [
            #keyPath(SproutCareTaskMO.plant.nickname),
            #keyPath(SproutCareTaskMO.plant.commonName),
            #keyPath(SproutCareTaskMO.plant.scientificName),
            #keyPath(SproutCareTaskMO.plant.thumbnailImageData)
        ]

        return request
    }

    public static func remindersFetchRequest() -> NSFetchRequest<SproutCareTaskMO> {
        let request = NSFetchRequest<SproutCareTaskMO>(entityName: SproutCareTaskMO.entityName)

        request.sortDescriptors = [
            SortDescriptors.sortByStatusDate(ascending: true),
            SortDescriptors.sortByPlantNickname(ascending: true),
            SortDescriptors.sortByPlantCommonName(ascending: true)
        ]

        let isDuePredicate = Predicates.statusPredicate(for: .due)
        let isScheduledPredicate = Predicates.isScheduledPredicate()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [isDuePredicate, isScheduledPredicate])

        return request
    }
}
