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
    @Published private(set) var counts = [(UUID, NSEntityDescription, Int)]()
    
    var viewContext: NSManagedObjectContext?
    
    private let allTypes = [
        SproutPlantMO.self,
        SproutCareTaskMO.self,
        SproutCareInformationMO.self,
        SproutImageDataMO.self
    ]
    
    private func makeFetchRequest(entityType: NSManagedObject.Type) -> NSFetchRequest<NSFetchRequestResult> {
        let request = entityType.fetchRequest()
        return request
    }
    
    func fetchCounts() {
        guard let context = viewContext else {
            counts = []
            return
        }
        
        counts = allTypes.map { type -> (UUID, NSEntityDescription, Int) in
            let count = try? context.count(for: makeFetchRequest(entityType: type))
            return (UUID(), type.entity(), count ?? 0)
        }
        .sorted(by: { lhs, rhs in
            lhs.1.name < rhs.1.name
                && lhs.2 < rhs.2
        })
    }
}
