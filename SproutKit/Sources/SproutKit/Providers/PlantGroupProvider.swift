//
//  File.swift
//  
//
//  Created by Ryan Thally on 6/25/21.
//

import CoreData
import Foundation

final class PlantGroupProvider: CachedProvider {
    var fetchedIDs: [NSManagedObjectID] = []
    var objects: [NSManagedObjectID:ManagedObjectType] = [:]
    let persistentContainer: NSPersistentContainer

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    typealias ManagedObjectType = SproutPlantMO
}
