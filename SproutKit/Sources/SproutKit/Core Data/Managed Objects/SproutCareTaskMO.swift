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

        setPrimitiveValue(UUID().uuidString, forKey: #keyPath(SproutCareTaskMO.identifier))
        setPrimitiveValue(Date(), forKey: #keyPath(SproutCareTaskMO.creationDate))
        setPrimitiveValue(Date(), forKey: #keyPath(SproutCareTaskMO.lastModifiedDate))

        markStatus = .due
        schedule = nil
    }

    public override func awakeFromFetch() {
        super.awakeFromFetch()

        hasSchedule = schedule != nil
        hasRecurrenceRule = recurrenceRule != nil

        updateUpNextGroupingDate()
    }

    override public func willSave() {
        super.willSave()

        updateUpNextGroupingDate()
        setPrimitiveValue(Date(), forKey: #keyPath(SproutCareTaskMO.lastModifiedDate))
    }

    func updateUpNextGroupingDate() {
        if let statusDate = statusDate {
            setPrimitiveValue(Calendar.current.startOfDay(for: statusDate), forKey: #keyPath(SproutCareTaskMO.upNextGroupingDate))
        } else {
            setPrimitiveValue(nil, forKey: #keyPath(SproutCareTaskMO.upNextGroupingDate))
        }
    }
}

// MARK: - Convenience methods for creating tasks
public extension SproutCareTaskMO {
    @discardableResult static func insertNewTask(of type: SproutCareType, into context: NSManagedObjectContext) -> SproutCareTaskMO {
        let newTask = SproutCareTaskMO(context: context)
        newTask.careInformation = SproutCareInformationMO.fetchOrInsertCareInformation(of: type, in: context)
        return newTask
    }

    @discardableResult static func insertNewTask(from existingTask: SproutCareTaskMO, into context: NSManagedObjectContext) throws -> SproutCareTaskMO {
        let templateTask = try context.existingObject(with: existingTask.objectID) as! SproutCareTaskMO

        let newTask = SproutCareTaskMO(context: context)
        newTask.careInformation = templateTask.careInformation

        if let recurrenceRule = templateTask.recurrenceRule {
            newTask.schedule = SproutCareTaskSchedule(startDate: Date(), recurrenceRule: recurrenceRule)
        }

        newTask.plant = templateTask.plant
        return newTask
    }
}
