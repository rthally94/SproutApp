//
//  NSPersistentContainer+Extensions.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/8/21.
//

import CoreData
import Foundation

extension NSPersistentContainer {
    func saveContextIfNeeded() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
