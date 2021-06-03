//
//  SproutIcon.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/11/21.
//

import CoreData
import UIKit

public class SproutIcon: NSManagedObject {
    static func createIconWithImage(_ image: UIImage?, inContext context: NSManagedObjectContext) -> SproutIcon {
        let icon = SproutIcon(context: context)
        icon.imageData = image?.pngData()
        return icon
    }

    static func createIconWithSymbol(symbolName: String, tintColor: UIColor?, inContext context: NSManagedObjectContext) -> SproutIcon {
        let icon = SproutIcon(context: context)
        icon.symbolName = symbolName
        icon.color = tintColor
        return icon
    }


    public override func willSave() {
        if plant == nil && careCategory == nil {
            self.managedObjectContext?.perform {
                self.managedObjectContext?.delete(self)
            }
        }

        super.willSave()
    }
}
