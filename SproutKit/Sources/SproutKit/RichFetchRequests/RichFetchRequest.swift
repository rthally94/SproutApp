//
//  RichFetchRequest.swift
//  
//
//  Created by Ryan Thally on 6/27/21.
//

import CoreData
import Foundation

public final class RichFetchRequest<ResultType>: NSFetchRequest<NSFetchRequestResult> where ResultType: NSFetchRequestResult {
    public var relationshipKeyPathsForRefreshing: Set<String> = []
}
