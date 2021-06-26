//
//  File.swift
//  
//
//  Created by Ryan Thally on 6/25/21.
//

import Foundation

extension SproutCareTaskMO {
    func markAsComplete() {
        let midnightToday = Calendar.current.startOfDay(for: Date())
        let midnightTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: midnightToday)!
        let isTodayTheDueDate = midnightToday <= dueDate && dueDate < midnightTomorrow

        if dueDate < midnightToday {
            // Late
            markAs(.late)
        } else if dueDate < midnightTomorrow {
            // Today
            markAs(.done)
        } else {
            // Early
            markAs(.done)
        }

        guard let context = managedObjectContext else { return }
        guard let typeKey = careInformation?.type, let type = SproutCareType(rawValue: typeKey) else { return }
        let newTask = Self.insertNewTask(of: type, into: context)
        newTask.schedule = schedule
    }
}
