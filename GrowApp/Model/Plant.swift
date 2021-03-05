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
    
    internal init(id: UUID = UUID(), name: String, type: PlantType, icon: Icon? = nil, tasks: [Task]) {
        self.id = id
        self.name = name
        self.type = type
        self.icon = icon ?? .symbol(name: "leaf.fill", foregroundColor: nil, backgroundColor: .systemBlue)
        self.tasks = tasks
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

extension Plant: Hashable, Equatable {
    static func == (lhs: Plant, rhs: Plant) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
