//
//  RelationshipKeyPath.swift
//  See https://www.avanderlee.com/swift/nsfetchedresultscontroller-observe-relationship-changes/
//
//  Created by Ryan Thally on 6/27/21.
//

import CoreData
import Foundation

public struct RelationshipKeyPath: Hashable {
    let sourcePropertyName: String
    let destinationEntityName: String
    let destinationPropertyName: String
    let inverseRelationshipKeyPath: String

    public init(keyPath: String, relationships: [String: NSRelationshipDescription]) {
        let splitKeyPath = keyPath.split(separator: ".")
        sourcePropertyName = String(splitKeyPath.first!)
        destinationPropertyName = String(splitKeyPath.last!)

        let relationship = relationships[sourcePropertyName]!
        destinationEntityName = relationship.destinationEntity!.name!
        inverseRelationshipKeyPath = relationship.inverseRelationship!.name

        [sourcePropertyName, destinationEntityName, destinationPropertyName].forEach { property in
            assert(!property.isEmpty, "Invalid key path is used")
        }
    }
}
