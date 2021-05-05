//
//  PlantGroupViewModel.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/5/21.
//

import Combine
import CoreData
import UIKit

enum PlantGroupView {
    case initial
    case newPlant
    case plantDetail
}

class PlantGroupViewModel {
    typealias Section = PlantGroupSection
    typealias Item = PlantGroupItem
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    private lazy var plantsProvider = PlantsProvider(managedObjectContext: persistentContainer.viewContext)
    var persistentContainer = AppDelegate.persistentContainer

    @Published private(set) var presentedView: PlantGroupView = .initial
    private(set) var selectedPlant: GHPlant?

    @Published private(set) var title: String? = "Your Plants"

    var snapshot: AnyPublisher<Snapshot, Never> {
        plantsProvider.$snapshot
            .map { snapshot in
                var newSnapshot = Snapshot()
                if let oldSnapshot = snapshot {
                    let sections = [Section(name: "All")]
                    newSnapshot.appendSections(sections)

                    zip(oldSnapshot.sectionIdentifiers, newSnapshot.sectionIdentifiers).forEach { sectionID, section in
                        let plantIDs = oldSnapshot.itemIdentifiers(inSection: sectionID)
                        let items: [Item] = plantIDs.compactMap { plantID in
                            guard let plant = self.plantsProvider.object(withID: plantID) else { return nil }
                            return Item(plant: plant)
                        }
                        newSnapshot.appendItems(items, toSection: section)
                    }
                }
                return newSnapshot
            }.eraseToAnyPublisher()
    }

    // MARK: - Task Methods
    func addNewPlant() {
        let viewContext = persistentContainer.viewContext

        do {
            let newPlant = try GHPlant.createDefaultPlant(inContext: viewContext)
            selectedPlant = newPlant
            presentedView = .newPlant
        } catch {
            fatalError("Unable to create new plant with default template: \(error)")
        }
    }

    func selectPlant(at indexPath: IndexPath) {
        selectedPlant = plantsProvider.object(at: indexPath)
        presentedView = .plantDetail
    }

    func showList() {
        selectedPlant = nil
        presentedView = .initial
    }
}
