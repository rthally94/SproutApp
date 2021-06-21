//
//  SproutCareTaskMO.swift
//  Sprout
//
//  Created by Ryan Thally on 6/16/21.
//

import CoreData

final class SproutCareTaskMO: NSManagedObject {
    override func awakeFromInsert() {
        super.awakeFromInsert()

        setPrimitiveValue(UUID().uuidString, forKey: #keyPath(SproutPlantMO.identifier))
        setPrimitiveValue(Date(), forKey: #keyPath(SproutPlantMO.creationDate))
        setPrimitiveValue(Date(), forKey: #keyPath(SproutPlantMO.lastModifiedDate))
    }

    override func willSave() {
        super.willSave()

        setPrimitiveValue(Date(), forKey: #keyPath(SproutPlantMO.lastModifiedDate))
    }
}

// Swift Properties
extension SproutCareTaskMO {
    // MARK: - Instance Properties
    var markStatus: SproutMarkStatus {
        get {
            SproutMarkStatus(rawValue: status ?? "") ?? .due
        }
    }

    var schedule: SproutCareTaskSchedule? {
        get {
            guard let startDate = startDate, let dueDate = dueDate, let recurrenceRule = recurrenceRule else { return nil }
            return SproutCareTaskSchedule(startDate: startDate, dueDate: dueDate, recurrenceRule: recurrenceRule)
        }
        set {
            hasSchedule = newValue != nil
            startDate = newValue?.startDate


            dueDate = newValue?.dueDate
            recurrenceRule = newValue?.recurrenceRule

            updateStatusProperties(for: markStatus)
        }
    }

    private(set) var recurrenceRule: SproutCareTaskRecurrenceRule? {
        get {
            switch recurrenceFrequency {
            case "daily":
                return SproutCareTaskRecurrenceRule.daily(Int(recurrenceInterval))
            case "weekly":
                return SproutCareTaskRecurrenceRule.weekly(Int(recurrenceInterval), recurrenceDaysOfWeek)
            case "monthly":
                return SproutCareTaskRecurrenceRule.monthly(Int(recurrenceInterval), recurrenceDaysOfMonth)
            default:
                return nil
            }
        }
        set {
            switch newValue {
            case let .daily(interval):
                hasRecurrenceRule = true
                recurrenceFrequency = "daily"
                recurrenceInterval = Int64(interval)
                recurrenceDaysOfWeek = nil
                recurrenceDaysOfMonth = nil
            case let .weekly(interval, weekdays):
                hasRecurrenceRule = true
                recurrenceFrequency = "weekly"
                recurrenceInterval = Int64(interval)
                recurrenceDaysOfWeek = weekdays
                recurrenceDaysOfMonth = nil
            case let .monthly(interval, days):
                hasRecurrenceRule = true
                recurrenceFrequency = "monthly"
                recurrenceInterval = Int64(interval)
                recurrenceDaysOfWeek = nil
                recurrenceDaysOfMonth = days
            default:
                hasRecurrenceRule = false
                recurrenceFrequency = nil
                recurrenceInterval = 0
                recurrenceDaysOfWeek = nil
                recurrenceDaysOfMonth = nil

            }
        }
    }

    // MARK: - Instance Methods
    func markAs(_ newStatus: SproutMarkStatus) {
        guard let moc = managedObjectContext else { return }
        moc.performAndWait {
            updateStatusProperties(for: newStatus)
        }

        do {
            try moc.save()
        } catch {
            print("Error saving context: \(error)")
            moc.rollback()
        }
    }

    private func updateStatusProperties(for newStatus: SproutMarkStatus) {
        status = newStatus.rawValue

        switch newStatus {
        case .due:
            statusDate = dueDate
        default:
            statusDate = Date()
        }
    }
}

// MARK: - Convenience methods for creating tasks
extension SproutCareTaskMO {
    @discardableResult private static func insertNewTask(into context: NSManagedObjectContext) -> SproutCareTaskMO {
        let newTask = SproutCareTaskMO(context: context)
        newTask.schedule = nil
        newTask.updateStatusProperties(for: .due)
        return newTask
    }

    @discardableResult static func insertNewTask(of type: SproutCareType, into context: NSManagedObjectContext) -> SproutCareTaskMO {
        let newTask = insertNewTask(into: context)
        newTask.careInformation = SproutCareInformationMO.fetchOrInsertCareInformation(of: type, in: context)
        return newTask
    }
}

// MARK: - Fetch Requests
extension SproutCareTaskMO {
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
