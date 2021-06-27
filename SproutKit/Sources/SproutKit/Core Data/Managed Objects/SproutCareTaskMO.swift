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

        markStatus = .due
        schedule = nil
    }

    public override func awakeFromFetch() {
        super.awakeFromFetch()

        hasSchedule = schedule != nil
        hasRecurrenceRule = recurrenceRule != nil
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
