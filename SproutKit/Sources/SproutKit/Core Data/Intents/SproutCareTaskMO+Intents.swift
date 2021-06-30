//
//  SproutCareTaskMO+Intents.swift
//  
//
//  Created by Ryan Thally on 6/25/21.
//

import Foundation

extension SproutCareTaskMO {
    public func markAsComplete() {
        guard markStatus == .due else { return }

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
        do {
            try SproutCareTaskMO.insertNewTask(from: self, into: context)
        } catch {
            print("Unable to create new task from template: \(error)")
        }
    }
}
