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
    
    var name: String
    var type: PlantType
    
    var icon: Icon
    
    var tasks: [Task]
    
    internal init(id: UUID = UUID(), name: String, type: PlantType, icon: Icon? = nil, tasks: [Task], careInfo: [TaskType: String]? = nil) {
        self.id = id
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

//MARK:- Intents
extension Plant {
    func logCare(for task: Task) {
        logCare(for: task, on: Date())
    }
    
    func logCare(for task: Task, on date: Date) {
        task.logCompletedCare(on: date)
    }
}

extension Plant {
    func getDateOfNextTask() -> Date {
        var min: Date! = nil
        for task in tasks {
            let nextCareDate = task.nextCareDate
            if min == nil || nextCareDate < min {
                min = nextCareDate
            }
        }
        
        return min
    }
    
    func tasksNeedingCare(on date: Date) -> [Task] {
        tasks.filter { $0.isDateInInterval(date)}
    }
}

extension Plant: Hashable, Equatable {
    static func == (lhs: Plant, rhs: Plant) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
