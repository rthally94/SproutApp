//
//  NSManagedObjectContext+Extensions.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/8/21.
//

import CoreData
import Foundation

extension NSManagedObjectContext {
    public func saveIfNeeded() throws {
        if self.hasChanges {
            try self.save()
        }
    }
}
