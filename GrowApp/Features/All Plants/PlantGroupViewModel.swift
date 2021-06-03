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
    case editPlant(SproutPlantMO)
    case plantDetail(SproutPlantMO)
}

class PlantGroupViewModel {
    typealias Section = PlantGroupSection
    typealias Item = PlantGroupItem
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    private lazy var plantsProvider = PlantsProvider(managedObjectContext: persistentContainer.viewContext)
    var persistentContainer = AppDelegate.persistentContainer

    @Published private(set) var presentedView: PlantGroupView = .initial

    @Published private(set) var navigationTitle: String? = "Your Plants"

    var snapshot: AnyPublisher<Snapshot, Never> {
        plantsProvider.$snapshot
            .map { snapshot in
                var newSnapshot = Snapshot()
                if let oldSnapshot = snapshot {
                    let sections = [Section(name: "All")]
                    newSnapshot.appendSections(sections)

                    zip(oldSnapshot.sectionIdentifiers, newSnapshot.sectionIdentifiers).forEach { sectionID, section in
                        let plantIDs = oldSnapshot.itemIdentifiers(inSection: sectionID)
                        var items = [Item]()
                        var itemsToReload = [Item]()
                        plantIDs.forEach { plantID in
                            if plantID.isTemporaryID {
                                print("PlantDetail - Found Temporary ID")
                            }
                            if let plant = self.plantsProvider.object(withID: plantID) {
                                let item = Item(plant: plant)
                                items.append(item)
                                if plant.isUpdated {
                                    itemsToReload.append(item)
                                }
                            }
                        }

                        newSnapshot.appendItems(items, toSection: section)
                        newSnapshot.reloadItems(itemsToReload)
                    }
                }
                return newSnapshot
            }.eraseToAnyPublisher()
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
}
