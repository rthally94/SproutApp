//
//  NSManagedObjectContext+Extension.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/1/21.
//

import CoreData
import Foundation

extension NSManagedObjectContext {
    func makeEditingContext() -> NSManagedObjectContext {
        let editingContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        editingContext.parent = self
        return editingContext
    }
}
