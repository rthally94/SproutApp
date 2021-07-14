//
//  TaskMarking.swift
//  Sprout
//
//  Created by Ryan Thally on 7/10/21.
//

import Foundation
import SproutKit

protocol TaskMarking {
    func markTaskAsComplete(_ task: SproutCareTaskMO)
}

extension TaskMarking {
    func markTaskAsComplete(_ task: SproutCareTaskMO) {
        guard let context = task.managedObjectContext else { return }
        context.performAndWait {
            task.markAsComplete()

            do {
                try SproutCareTaskMO.insertNewTask(from: task, into: context)
            } catch {
                print("Unable to create new task from template: \(error)")
            }

            do {
                let result = try context.saveIfNeeded()
                print("Task context saved: ", result)
            } catch {
                print("Error saving task context: \(error)")
                context.rollback()
            }
        }
    }
}
