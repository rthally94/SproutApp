//
//  PlantGroupViewModel.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/5/21.
//

import Combine
import CoreData
import UIKit
import SproutKit

enum PlantGroupView {
    case initial
    case newPlant
    case editPlant(SproutPlantMO)
    case plantDetail(SproutPlantMO)
}

class PlantGroupViewModel: ObservableObject {
    typealias Section = String
    typealias Item = NSManagedObjectID
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    private var plantsProvider: PlantsProvider
    var persistentContainer: NSPersistentContainer

    @Published private(set) var presentedView: PlantGroupView = .initial
    @Published private(set) var navigationTitle: String? = "Your Plants"

    var snapshot: AnyPublisher<Snapshot?, Never> {
        plantsProvider.$snapshot
            .eraseToAnyPublisher()
    }

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        plantsProvider = PlantsProvider(managedObjectContext: persistentContainer.viewContext)
    }

    // MARK: - Task Methods
    func addNewPlant() {
        presentedView = .newPlant
    }

    func selectPlant(at indexPath: IndexPath) {
        let selectedPlant = plantsProvider.object(at: indexPath)
        presentedView = .plantDetail(selectedPlant)
    }

    func showList() {
        presentedView = .initial
    }

    func plant(withID id: Item) -> SproutPlantMO? {
        plantsProvider.object(withID: id)
    }
}
