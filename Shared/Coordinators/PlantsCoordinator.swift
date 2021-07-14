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
    var storageProvider: StorageProvider

    init(navigationController: UINavigationController, storageProvider: StorageProvider) {
        self.navigationController = navigationController
        self.storageProvider = storageProvider
    }

    func start() {
        let vc = PlantGroupViewController()
        vc.persistentContainer = storageProvider.persistentContainer
        vc.plantsProvider = PlantsProvider(managedObjectContext: storageProvider.persistentContainer.viewContext)
        vc.coordinator = self

        vc.tabBarItem = UITabBarItem(title: "Plants", image: UIImage(systemName: "leaf.fill"), tag: 1)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.pushViewController(vc, animated: false)
    }
}

extension PlantsCoordinator: PlantListCoordinator {
    func createNewPlant() {
        let editingContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        editingContext.parent = storageProvider.persistentContainer.viewContext
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
        storageProvider.persistentContainer.viewContext.delete(plant)
        storageProvider.persistentContainer.saveContextIfNeeded()
    }

    func showDetail(for plant: SproutPlantMO) {
        guard let vc = PlantDetailViewController(plant: plant.objectID, storageProvider: storageProvider) else { return }
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
}

extension PlantsCoordinator: PlantDetailCoordinator { }

extension PlantsCoordinator: EditorCoordinatorDelegate {
    func editorCoordinator(_ coordinator: PlantEditorCoordinator, didUpdatePlant plant: SproutPlantMO) {
        if let detailVC = navigationController.topViewController as? PlantDetailViewController {
            detailVC.refreshUI()
        }

        if let plant = try? storageProvider.persistentContainer.viewContext.existingObject(with: plant.objectID) {
            storageProvider.persistentContainer.viewContext.refresh(plant, mergeChanges: true)
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
            storageProvider.persistentContainer.saveContextIfNeeded()

            if let detailVC = navigationController.topViewController as? PlantDetailViewController {
                detailVC.refreshUI(animated: false)
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
