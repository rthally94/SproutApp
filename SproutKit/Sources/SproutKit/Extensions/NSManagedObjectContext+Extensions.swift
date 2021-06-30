//
//  NSManagedObjectContext+Extensions.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/8/21.
//

import CoreData
import Foundation

extension NSManagedObjectContext {
    @discardableResult public func saveIfNeeded() throws -> Bool {
        if self.hasChanges {
            try self.save()
            return true
        }

        return false
    }
}
