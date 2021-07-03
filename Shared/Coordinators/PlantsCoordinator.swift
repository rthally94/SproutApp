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
}

extension PlantsCoordinator: PlantListCoordinator {
    func createNewPlant() {
        let editingContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        editingContext.parent = persistentContainer.viewContext
        let newPlant = SproutPlantMO.insertNewPlant(using: .newPlant(), into: editingContext)
        showPlantEditor(plant: newPlant)
    }

    func edit(plant: SproutPlantMO) {
        guard let parentContext = plant.managedObjectContext else { return }
        let editingContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        editingContext.parent = parentContext
        showPlantEditor(plant: plant)
    }

    private func showPlantEditor(plant: SproutPlantMO) {
        guard let coordinator = EditorCoordinator(
            navigationController: UINavigationController(),
            plant: plant
        ) else { return }
        coordinator.delegate = self

        childCoordinators.append(coordinator)
        coordinator.start()
        navigationController.present(coordinator.navigationController, animated: true)
    }

    func delete(plant: SproutPlantMO) {
        persistentContainer.viewContext.delete(plant)
        persistentContainer.saveContextIfNeeded()
    }

    func showDetail(for plant: SproutPlantMO) {
        let vc = PlantDetailViewController()
        vc.coordinator = self
        vc.persistentContainer = persistentContainer
        vc.plantID = plant.objectID
        navigationController.pushViewController(vc, animated: true)
    }
}

extension PlantsCoordinator: PlantDetailCoordinator { }

extension PlantsCoordinator: EditorCoordinatorDelegate {
    func editorCoordinator(_ coordinator: EditorCoordinator, didUpdatePlant plant: SproutPlantMO) {
        if (try? persistentContainer.viewContext.existingObject(with: plant.objectID))?.isUpdated == true,
            let detailVC = navigationController.topViewController as? PlantDetailViewController {
            detailVC.reload()
        }

        do {
            try coordinator.managedObjectContext.saveIfNeeded()
        } catch {
            coordinator.managedObjectContext.rollback()
        }

        persistentContainer.viewContext.refresh(plant, mergeChanges: true)
        persistentContainer.saveContextIfNeeded()
    }

    func editorCoordinatorDidFinish(_ coordinator: EditorCoordinator) {
        if let index = childCoordinators.firstIndex(where: { $0 === coordinator }) {
            childCoordinators.remove(at: index)
        }

        coordinator.navigationController.dismiss(animated: true)
    }
}
