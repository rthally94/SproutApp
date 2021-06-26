//
//  SproutCareTaskMO.swift
//  Sprout
//
//  Created by Ryan Thally on 6/16/21.
//

import CoreData

public final class SproutCareTaskMO: NSManagedObject {
    override public func awakeFromInsert() {
        super.awakeFromInsert()

        setPrimitiveValue(UUID().uuidString, forKey: #keyPath(SproutPlantMO.identifier))
        setPrimitiveValue(Date(), forKey: #keyPath(SproutPlantMO.creationDate))
        setPrimitiveValue(Date(), forKey: #keyPath(SproutPlantMO.lastModifiedDate))

        schedule = nil
        updateStatusProperties(for: .due)
    }

    override public func willSave() {
        super.willSave()

        setPrimitiveValue(Date(), forKey: #keyPath(SproutPlantMO.lastModifiedDate))
    }
}

// MARK: - Convenience methods for creating tasks
public extension SproutCareTaskMO {
    @discardableResult static func insertNewTask(of type: SproutCareType, into context: NSManagedObjectContext) -> SproutCareTaskMO {
        let newTask = SproutCareTaskMO(context: context)
        newTask.careInformation = SproutCareInformationMO.fetchOrInsertCareInformation(of: type, in: context)
        return newTask
    }
}


// Swift Properties
extension SproutCareTaskMO {
    // MARK: - Instance Properties
    var markStatus: SproutMarkStatus {
        SproutMarkStatus(rawValue: status ?? "") ?? .due        
    }

    var schedule: SproutCareTaskSchedule? {
        get {
            guard let startDate = startDate, let dueDate = dueDate else { return nil }
            return SproutCareTaskSchedule(startDate: startDate, dueDate: dueDate, recurrenceRule: recurrenceRule)
        }
        set {
            guard markStatus != .done else { return }

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
                recurrenceInterval = 1
                recurrenceDaysOfWeek = nil
                recurrenceDaysOfMonth = nil

            }
        }
    }

    // MARK: - Instance Methods
    func markAs(_ newStatus: SproutMarkStatus) throws {
        guard let moc = managedObjectContext else { return }
        moc.performAndWait {
            updateStatusProperties(for: newStatus)
        }

        try moc.saveIfNeeded()
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
