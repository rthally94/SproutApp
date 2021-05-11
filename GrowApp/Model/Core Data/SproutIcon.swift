//
//  SproutIcon.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/11/21.
//

import CoreData

public class SproutIcon: NSManagedObject {
    public override func willSave() {
        super.willSave()

        if plant == nil && careCategory == nil {
            self.managedObjectContext?.perform {
                self.managedObjectContext?.delete(self)
            }
        }
    }
}
