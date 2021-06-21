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
        do {
            try viewContext.saveIfNeeded()
        } catch {
            print("Unable to save persistent container: \(error)")
        }
    }
}
