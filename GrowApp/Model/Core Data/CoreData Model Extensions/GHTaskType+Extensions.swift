//
//  CareInfoType+Extensions.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/7/21.
//

import CoreData
import UIKit

extension CareCategory {
    static func wateringTaskType(context: NSManagedObjectContext) -> CareCategory {
        let wateringTask = CareCategory(context: context)
        wateringTask.name = "Watering"
        
        let wateringIcon = SproutIcon(context: context)
        wateringIcon.symbolName = "drop.fill"
        wateringIcon.color = UIColor(named: "ghBlue")
        wateringTask.icon = wateringIcon
        
        return wateringTask
    }
    
    static func fertilizingTaskType(context: NSManagedObjectContext) -> CareCategory {
        let fertilizingTask = CareCategory(context: context)
        fertilizingTask.name = "Fertilizing"
        
        let fertilizingIcon = SproutIcon(context: context)
        fertilizingIcon.symbolName = "leaf.fill"
        fertilizingIcon.color = UIColor(named: "ghOrange")
        fertilizingTask.icon = fertilizingIcon
        
        return fertilizingTask
    }
    
    static func pruningTaskType(context: NSManagedObjectContext) -> CareCategory {
        let pruningTask = CareCategory(context: context)
        pruningTask.name = "Watering"
        
        let pruningIcon = SproutIcon(context: context)
        pruningIcon.symbolName = "scissors"
        pruningIcon.color = UIColor(named: "ghGreen")
        pruningTask.icon = pruningIcon
        
        return pruningTask
    }
    
    static func pottingTaskType(context: NSManagedObjectContext) -> CareCategory {
        let pottingTask = CareCategory(context: context)
        pottingTask.name = "Re-Potting"
        
        let pottingIcon = SproutIcon(context: context)
        pottingIcon.symbolName = "rectangle.roundedbottom.fill"
        pottingIcon.color = UIColor(named: "ghRed")
        pottingTask.icon = pottingIcon
        
        return pottingTask
    }
}
