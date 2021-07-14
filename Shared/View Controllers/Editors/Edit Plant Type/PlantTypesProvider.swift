//
//  PlantTypesProvider.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/2/21.
//

import CoreData
import UIKit
import SproutKit

class PlantTypesProvider: NSObject {
    private var allTypes: [SproutPlantTemplate] = SproutPlantTemplate.allTypes
    private var selectedItem: Item?
    @Published var snapshot: NSDiffableDataSourceSnapshot<Section, Item>?

    enum Section: Int, Hashable, CaseIterable, CustomStringConvertible {
        case recent
        case allPlants

        var description: String {
            switch self {
            case .recent: return "Recent Plants"
            case .allPlants: return "All Plants"
            }
        }
    }

    typealias Item = SproutPlantTemplate

    override init() {
        super.init()

        // Make Snapshot
        var newSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        newSnapshot.appendSections([.allPlants])
        newSnapshot.appendItems(allTypes)
        snapshot = newSnapshot
    }

    func template(for plant: SproutPlantMO) -> SproutPlantTemplate? {
        return allTypes.first(where: {
            $0.scientificName == plant.scientificName
        })
    }

    func reloadItems(_ items: [Item]) {
        let idsToReload = Array(Set(items))
        var newSnapshot = snapshot
        newSnapshot?.reloadItems(idsToReload)
        snapshot = newSnapshot
    }
}
