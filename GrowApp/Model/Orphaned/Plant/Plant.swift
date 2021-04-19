//
//  Plant.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/15/21.
//

import Foundation
import UIKit

class Plant: NSObject, NSCopying {
    typealias IDType = String
    
    var id: IDType
    let creationDate: Date
    
    var name: String
    var type: PlantType?
    
    var icon: Icon
    
    var tasks: [Task]
    
    convenience init(name: String, icon: Icon, type: PlantType?, tasks: [Task]) {
        self.init(id: UUID().uuidString, creationDate: Date(), name: name, type: type, icon: icon, tasks: tasks)
    }
    
    init(id: String, creationDate: Date, name: String, type: PlantType?, icon: Icon, tasks: [Task]) {
        self.id = id
        self.creationDate = creationDate
        self.name = name
        self.type = type
        self.icon = icon
        self.tasks = tasks
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Plant(id: self.id, creationDate: self.creationDate, name: self.name, type: self.type, icon: self.icon, tasks: self.tasks)
    }
}

// TaskStore CRUD
extension Plant {
    @discardableResult func createTask() -> Task {
        let newTask = Task(type: .watering, interval: .none, startingDate: Date())
        tasks.append(newTask)
        return newTask
    }
    
    @discardableResult func removeTask(_ taskToRemove: Task) -> Task? {
        if let indexToRemove = tasks.firstIndex(of: taskToRemove) {
            return tasks.remove(at: indexToRemove)
        }
        
        return nil
    }
}

// MARK: - Intents
extension Plant {
    func logCare(for task: Task) {
        logCare(for: task, on: Date())
    }
    
    func logCare(for task: Task, on date: Date) {
        if let taskIndex = tasks.firstIndex(of: task) {
            tasks[taskIndex].logCompletedCare(on: date)
        }
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
        
        let today = Calendar.current.startOfDay(for: Date())
        let firstDate = temp.sorted().first
        
        if let firstDate = firstDate, firstDate < today {
            return today
        } else {
            return firstDate
        }
    }
    
    func getOptimalDateOfNextTask() -> Date? {
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
            if task.isLate() {
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
            if task.isLate() {
                return task
            } else {
                return nil
            }
        }
    }
    
    func nextTasks() -> [Task] {
        let late = Set(lateTasks())
        let today = Set(todaysTasks())
        
        if !late.isEmpty || !today.isEmpty {
            let filteredLate = late.subtracting(today)
            let filteredLateSorted = filteredLate.sorted(by: { $0.type.description < $1.type.description })
            let todaySorted = today.sorted(by: { $0.type.description < $1.type.description })
            return filteredLateSorted + todaySorted
        } else if let nextTaskDate = getOptimalDateOfNextTask() {
            return tasksNeedingCare(on: nextTaskDate)
        } else {
            return []
        }
    }
}
