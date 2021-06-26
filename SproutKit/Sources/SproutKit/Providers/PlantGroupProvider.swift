//
//  File.swift
//  
//
//  Created by Ryan Thally on 6/25/21.
//

import CoreData
import Foundation

public final class PlantGroupProvider: CachedProvider {
    public var fetchedIDs: [NSManagedObjectID] = []
    public var objects: [NSManagedObjectID:ManagedObjectType] = [:]
    public let persistentContainer: NSPersistentContainer

    public init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    public typealias ManagedObjectType = SproutPlantMO
}
