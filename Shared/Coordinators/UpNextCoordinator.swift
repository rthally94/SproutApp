//
//  UpNextCoordinator.swift
//  Sprout
//
//  Created by Ryan Thally on 6/29/21.
//

import CoreData
import UIKit
import SproutKit

final class UpNextCoordinator: NSObject, Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var persistentContainer: NSPersistentContainer

    init(navigationController: UINavigationController, persistentContainer: NSPersistentContainer) {
        self.navigationController = navigationController
        self.persistentContainer = persistentContainer
    }

    func start() {
        let vc = UpNextViewController()
        vc.persistentContainer = persistentContainer
        vc.provider = UpNextProvider(managedObjectContext: persistentContainer.viewContext)
        vc.coordinator = self

        vc.tabBarItem = UITabBarItem(title: "Up Next", image: UIImage(systemName: "text.badge.checkmark"), tag: 0)

        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.pushViewController(vc, animated: false)
    }

    // MARK: - Intents
    func markAsComplete(task: SproutCareTaskMO) {
        persistentContainer.performBackgroundTask { context in
            guard let backgroundTask = try? context.existingObject(with: task.objectID) as? SproutCareTaskMO else { return }
            backgroundTask.markAsComplete()

            do {
                let result = try context.saveIfNeeded()
                print("Background Context Saved: ", result)
            } catch {
                print("Error saving background context: \(error)")
                context.rollback()
            }
        }
    }
}
