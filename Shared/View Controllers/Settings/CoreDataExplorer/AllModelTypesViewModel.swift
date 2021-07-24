//
//  AllModelTypeViewModel.swift
//  Sprout
//
//  Created by Ryan Thally on 7/24/21.
//

import CoreData
import Foundation
import SproutKit

final class AllModelTypesViewModel: ObservableObject {
    @Published private(set) var counts = [(String, Int)]()
    
    var viewContext: NSManagedObjectContext?
    
    private let allTypes = [
        SproutPlantMO.self,
        SproutCareTaskMO.self,
        SproutCareInformationMO.self,
        SproutImageDataMO.self
    ]
    
    private var fetchRequests: [NSFetchRequest<NSFetchRequestResult>] {
        allTypes.map {
            let request = $0.fetchRequest()
            
            return request
        }
    }
    
    func fetchCounts() {
        guard let context = viewContext else {
            counts = []
            return
        }
        
        let allCounts = fetchRequests.reduce(into: [String: Int](), { counts, request in
            let count = try? context.count(for: request)
            counts[request.entityName!] = count ?? 0
        })
        
        counts = allCounts.sorted(by: { lhs, rhs in
            lhs.key < rhs.key
                && lhs.value < rhs.value
        })
    }
}
