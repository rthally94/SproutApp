//
//  GHTaskType+Extensions.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/7/21.
//

import CoreData
import UIKit

extension GHTaskType {
    static func wateringTaskType(context: NSManagedObjectContext) -> GHTaskType {
        let wateringTask = GHTaskType(context: context)
        wateringTask.name = "Watering"
        
        let wateringIcon = GHIcon(context: context)
        wateringIcon.symbolName = "drop.fill"
        wateringIcon.color = UIColor(named: "ghBlue")
        wateringTask.icon = wateringIcon
        
        return wateringTask
    }
    
    static func fertilizingTaskType(context: NSManagedObjectContext) -> GHTaskType {
        let fertilizingTask = GHTaskType(context: context)
        fertilizingTask.name = "Fertilizing"
        
        let fertilizingIcon = GHIcon(context: context)
        fertilizingIcon.symbolName = "leaf.fill"
        fertilizingIcon.color = UIColor(named: "ghOrange")
        fertilizingTask.icon = fertilizingIcon
        
        return fertilizingTask
    }
    
    static func pruningTaskType(context: NSManagedObjectContext) -> GHTaskType {
        let pruningTask = GHTaskType(context: context)
        pruningTask.name = "Watering"
        
        let pruningIcon = GHIcon(context: context)
        pruningIcon.symbolName = "scissors"
        pruningIcon.color = UIColor(named: "ghGreen")
        pruningTask.icon = pruningIcon
        
        return pruningTask
    }
    
    static func pottingTaskType(context: NSManagedObjectContext) -> GHTaskType {
        let pottingTask = GHTaskType(context: context)
        pottingTask.name = "Re-Potting"
        
        let pottingIcon = GHIcon(context: context)
        pottingIcon.symbolName = "rectangle.roundedbottom.fill"
        pottingIcon.color = UIColor(named: "ghRed")
        pottingTask.icon = pottingIcon
        
        return pottingTask
    }
}
