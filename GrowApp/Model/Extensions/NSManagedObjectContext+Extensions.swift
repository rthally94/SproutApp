//
//  NSManagedObjectContext+Extensions.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/8/21.
//

import CoreData
import Foundation

extension NSManagedObjectContext {
    func persist(block: @escaping () -> Void) {
        perform {
            block()
            
            if self.hasChanges {
                do {
                    try self.save()
                } catch {
                    self.rollback()
                }
            }
        }
    }
}
