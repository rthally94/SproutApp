//
//  UpNextCoordinator.swift
//  Sprout
//
//  Created by Ryan Thally on 6/29/21.
//

import CoreData
import UIKit
import SproutKit

final class UpNextCoordinator: NSObject, Coordinator, TaskMarking {
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

    // Intents
    func markTaskAsComplete(_ task: SproutCareTaskMO) {
        guard let context = task.managedObjectContext else { return }
        context.perform {
            task.markAsComplete()

            do {
                let result = try context.saveIfNeeded()
                print("Task status saved to context: ", result)
            } catch {
                print("Error saving task status to context: \(error)")
                context.rollback()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            context.perform {
                do {
                    try SproutCareTaskMO.insertNewTask(from: task, into: context)
                } catch {
                    print("Unable to create new task from template: \(error)")
                }

                do {
                    let result = try context.saveIfNeeded()
                    print("New task saved in context: ", result)
                } catch {
                    print("Error saving new task to context: \(error)")
                    context.rollback()
                }
            }
        }
    }
}
