//
//  CoreDataMetadataProtocol.swift
//  Sprout
//
//  Created by Ryan Thally on 6/15/21.
//

import CoreData

protocol Managed: NSFetchRequestResult {
    static var entityName: String { get }
}

extension NSManagedObject: Managed { }
extension Managed where Self: NSManagedObject {
    static var entityName: String {
        return String(describing: self)
    }

    static var fetchRequest: NSFetchRequest<Self> {
        return NSFetchRequest<Self>(entityName: entityName)
    }
}
