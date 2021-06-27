//
//  ManagedMetadata.swift
//  Sprout
//
//  Created by Ryan Thally on 6/16/21.
//

import CoreData

protocol ManagedMetadata: NSFetchRequestResult {
    var id: String? { get }
    var creationDate: Date? { get }
    var lastModifiedDate: Date? { get }
}
