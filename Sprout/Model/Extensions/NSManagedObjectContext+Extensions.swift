//
//  NSManagedObjectContext+Extensions.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/8/21.
//

import CoreData
import Foundation

extension NSManagedObjectContext {
    func saveIfNeeded() throws {
        if self.hasChanges {
            try self.save()
        }
    }

    func persist(block: @escaping () -> Void, completion: (() -> Void)? = nil) {
        perform {
            block()
            
            if self.hasChanges {
                do {
                    try self.save()
                } catch {
                    self.rollback()
                }
            }
            completion?()
        }
    }
}
