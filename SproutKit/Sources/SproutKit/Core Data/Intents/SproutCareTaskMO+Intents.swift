//
//  SproutCareTaskMO+Intents.swift
//  
//
//  Created by Ryan Thally on 6/25/21.
//

import Foundation

extension SproutCareTaskMO {
    public func markAsComplete() {
        let dueDate = dueDate ?? Date()
        let midnightToday = Calendar.current.startOfDay(for: Date())
        let midnightTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: midnightToday)!

        if dueDate < midnightToday {
            // Late
            markStatus = .late
        } else if dueDate < midnightTomorrow {
            // Today
            markStatus = .done
        } else {
            // Early
            markStatus = .done
        }

        guard let context = self.managedObjectContext else { return }
        context.performAndWait {
            guard let typeKey = self.careInformation?.type, let type = SproutCareType(rawValue: typeKey) else { return }
            let newTask = Self.insertNewTask(of: type, into: context)
            newTask.schedule = self.schedule
            newTask.plant = self.plant
        }
    }
}
