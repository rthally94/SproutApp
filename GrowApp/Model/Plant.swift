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
    var scientific_name: String?
    var common_names: [String]
    
    var iconImage: UIImage?
    
    var tasks: [Task]
    
    internal init(id: UUID = UUID(), name: String, scientific_name: String? = nil, common_names: [String], iconImage: UIImage? = nil, tasks: [Task]) {
        self.id = id
        self.name = name
        self.scientific_name = scientific_name
        self.common_names = common_names
        self.iconImage = iconImage
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
