//
//  SproutCareHistoryMO.swift
//  GrowApp
//
//  Created by Ryan Thally on 6/2/21.
//

import CoreData
import UIKit

class SproutCareHistoryMO: NSManagedObject {
    enum SproutTaskStatus: String {
        case complete
    }

    static func createNewLog(for task: SproutCareTaskMO, status: SproutTaskStatus, completion: @escaping (SproutCareHistoryMO) -> Void) throws {
        guard let context = task.managedObjectContext else { throw NSManagedObjectError.noManagedObjectContextError }
        context.perform {
            let newLog = SproutCareHistoryMO(context: context)
            newLog.id = UUID().uuidString
            newLog.creationDate = Date()

            newLog.status = status.rawValue
            newLog.statusDate = Date()
            newLog.taskType = task.taskType
            newLog.careTask = task
            completion(newLog)
        }
    }
}
