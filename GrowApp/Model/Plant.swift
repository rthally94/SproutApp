//
//  Plant.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/15/21.
//

import Foundation
import UIKit

class Plant {
    var id: UUID
    let creationDate: Date
    
    var name: String
    var type: PlantType
    
    var icon: Icon
    
    var tasks: [Task]
    
    internal init(id: UUID = UUID(), creationDate: Date = Date(), name: String, type: PlantType, icon: Icon? = nil, tasks: [Task], careInfo: [TaskType: String]? = nil) {
        self.id = id
        self.creationDate = creationDate
        self.name = name
        self.type = type
        self.icon = icon ?? .symbol(name: "leaf.fill", foregroundColor: nil, backgroundColor: .systemBlue)
        self.tasks = tasks
        
        tasks.forEach { task in
            if let info = careInfo?.first(where: { key, _ in
                task.type == key
            }) {
                task.careInfo = .text(info.value)
            }
        }
    }
}

// MARK: - Intents

extension Plant {
    func logCare(for task: Task) {
        logCare(for: task, on: Date())
    }
    
    func logCare(for task: Task, on date: Date) {
        task.logCompletedCare(on: date)
    }
}

extension Plant {
    func getDateOfNextTask() -> Date? {
        let temp: [Date] = tasks.compactMap { task in
            if let lastCareDate = task.lastCareDate {
                return task.nextCareDate(after: lastCareDate)
            } else {
                return nil
            }
        }
        return temp.sorted().first
    }
    
    func tasksNeedingCare(on date: Date) -> [Task] {
        tasks.filter { $0.isDateInInterval(date) }
    }
    
    func todaysTasks() -> [Task] {
        tasks.compactMap { task in
            if let lastCareDate = task.lastCareDate, let nextCareDate = task.nextCareDate(after: lastCareDate), nextCareDate < Calendar.current.startOfDay(for: Date()) {
                // Late Tasks
                return task
            } else if task.isDateInInterval(Date()) {
                // Today's Tasks
                return task
            } else {
                return nil
            }
        }
    }
    
    func lateTasks() -> [Task] {
        tasks.compactMap { task in
            if let lastCareDate = task.lastCareDate, let nextCareDate = task.nextCareDate(after: lastCareDate), nextCareDate < Calendar.current.startOfDay(for: Date()) {
                return task
            } else {
                return nil
            }
        }
    }
}

extension Plant: Hashable, Equatable {
    static func == (lhs: Plant, rhs: Plant) -> Bool {
        lhs.id == rhs.id
            && lhs.creationDate == rhs.creationDate
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(creationDate)
    }
}
