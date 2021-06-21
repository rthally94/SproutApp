//
//  File.swift
//  
//
//  Created by Ryan Thally on 6/21/21.
//

import CoreData
import XCTest
@testable import SproutKit

public class CoreDataTestCase: XCTestCase {
    public var storageProvider: StorageProvider!
    public var moc: NSManagedObjectContext {
        storageProvider.persistentContainer.viewContext
    }

    override public func setUpWithError() throws {
        storageProvider = StorageProvider(storeType: .inMemory)
    }

}
