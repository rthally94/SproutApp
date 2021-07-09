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

        vc.tabBarItem = UITabBarItem(title: "Plants", image: UIImage(systemName: "leaf.fill"), tag: 1)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.pushViewController(vc, animated: false)
    }
}

extension PlantsCoordinator: PlantListCoordinator {
    func createNewPlant() {
        let editingContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        editingContext.parent = persistentContainer.viewContext
        let newPlant = SproutPlantMO.insertNewPlant(into: editingContext)
        showPlantEditor(plant: newPlant)
    }

    func edit(plant: SproutPlantMO) {
        guard let parentContext = plant.managedObjectContext else { return }
        let editingContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        editingContext.parent = parentContext
        showPlantEditor(plant: plant)
    }

    private func showPlantEditor(plant: SproutPlantMO) {
        guard let coordinator = PlantEditorCoordinator(
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
    func editorCoordinator(_ coordinator: PlantEditorCoordinator, didUpdatePlant plant: SproutPlantMO) {
        if let detailVC = navigationController.topViewController as? PlantDetailViewController {
            detailVC.reload()
        }

        if let plant = try? persistentContainer.viewContext.existingObject(with: plant.objectID) {
            persistentContainer.viewContext.refresh(plant, mergeChanges: true)
        }
    }

    func editorCoordinatorDidFinish(_ coordinator: PlantEditorCoordinator, status: DismissStatus) {
        switch status {
        case .canceled:
            coordinator.managedObjectContext.rollback()
        case .saved:
            do {
                try coordinator.managedObjectContext.saveIfNeeded()
            } catch {
                print("\(#function) - Unable to save context: \(error)")
            }
            persistentContainer.saveContextIfNeeded()

            if let detailVC = navigationController.topViewController as? PlantDetailViewController {
                detailVC.reload()
            }

        default:
            break
        }

        if let index = childCoordinators.firstIndex(where: { $0 === coordinator }) {
            childCoordinators.remove(at: index)
        }

        coordinator.navigationController.dismiss(animated: true)
    }
}
