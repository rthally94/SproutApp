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
    var storageProvider: StorageProvider

    init(navigationController: UINavigationController, storageProvider: StorageProvider) {
        self.navigationController = navigationController
        self.storageProvider = storageProvider
    }

    func start() {
        let upNextProvider = UpNextProvider(storageProvider: storageProvider)
        let vc = UpNextViewController(dataProvider: upNextProvider)
        vc.delegate = self

        vc.tabBarItem = UITabBarItem(title: "Up Next", image: UIImage(systemName: "text.badge.checkmark"), tag: 0)
        vc.title = "Up Next"

        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.pushViewController(vc, animated: false)
    }

    // MARK: - Intents
    func markAsComplete(task: SproutCareTaskMO) {
        guard let context = task.managedObjectContext else { return }
        context.perform {
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.storageProvider.persistentContainer.performBackgroundTask { context in
                do {
                    try SproutCareTaskMO.insertNewTask(from: task, into: context)
                } catch {
                    print("Unable to create new task from template: \(error)")
                }

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
}
