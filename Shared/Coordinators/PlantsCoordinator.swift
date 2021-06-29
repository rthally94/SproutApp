//
//  PlantsCoordinator.swift
//  Sprout
//
//  Created by Ryan Thally on 6/29/21.
//

import SproutKit
import CoreData
import UIKit

final class PlantsCoordinator: NSObject, Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var persistentContainer: NSPersistentContainer

    init(navigationController: UINavigationController, persistentContainer: NSPersistentContainer) {
        self.navigationController = navigationController
        self.persistentContainer = persistentContainer
    }

    func start() {
        let vc = PlantGroupViewController()
        vc.persistentContainer = persistentContainer
        vc.plantsProvider = PlantsProvider(managedObjectContext: persistentContainer.viewContext)
        vc.coordinator = self

        vc.tabBarItem = UITabBarItem(title: "Plants", image: UIImage(systemName: "house.fill"), tag: 1)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.pushViewController(vc, animated: false)
    }

    func showDetail(plant: SproutPlantMO) {
        let vc = PlantDetailViewController()
        vc.persistentContainer = persistentContainer
        vc.plantID = plant.objectID
        navigationController.pushViewController(vc, animated: true)
    }

    func addNewPlant() {
        let newPlant = SproutPlantMO.insertNewPlant(using: .newPlant(), into: persistentContainer.viewContext)
        edit(plant: newPlant)
    }

    func edit(plant: SproutPlantMO) {
        let editingContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        editingContext.parent = persistentContainer.viewContext
        let vc = AddEditPlantViewController(plant: plant, editingContext: editingContext)
        vc.delegate = self
        navigationController.present(vc.wrappedInNavigationController(), animated: true)
    }

    func delete(plant: SproutPlantMO) {
        persistentContainer.viewContext.delete(plant)
        persistentContainer.saveContextIfNeeded()
    }
}

extension PlantsCoordinator: AddEditPlantViewControllerDelegate {
    func plantEditor(_ editor: AddEditPlantViewController, didUpdatePlant plant: SproutPlantMO) {
        guard let plant = try? persistentContainer.viewContext.existingObject(with: plant.objectID) else { return }
        persistentContainer.viewContext.refresh(plant, mergeChanges: true)
        persistentContainer.saveContextIfNeeded()
        editor.dismiss(animated: true)
    }

    func plantEditorDidCancel(_ editor: AddEditPlantViewController) {
        editor.dismiss(animated: true)
    }
}

