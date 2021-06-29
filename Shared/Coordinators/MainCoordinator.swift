//
//  MainCoordinator.swift
//  Sprout
//
//  Created by Ryan Thally on 6/29/21.
//

import CoreData
import SwiftUI
import UIKit

final class MainCoordinator: NSObject, Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var mainController: UIViewController?
    var persistentContainer: NSPersistentContainer

    init(navigationController: UINavigationController, persistentContainer: NSPersistentContainer) {
        self.navigationController = navigationController
        self.persistentContainer = persistentContainer
    }

    func start() {
        showMain()

        if !UserDefaults.standard.hasLaunched {
            showOnboarding()
        }
    }

    private func showMain() {
        let vc = SproutTabBarController()
        vc.coordinator = self

        let upNext = UpNextCoordinator(navigationController: UINavigationController(), persistentContainer: AppDelegate.persistentContainer)
        let plants = PlantsCoordinator(navigationController: UINavigationController(), persistentContainer: AppDelegate.persistentContainer)
        let settingsVC: UIViewController = {
            let view = SettingsView()
            let hostedView = UIHostingController(rootView: view)
            hostedView.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), selectedImage: UIImage(systemName: "gear"))
            hostedView.tabBarItem.tag = 3
            return hostedView
        }()

        upNext.start()
        plants.start()

        childCoordinators += [
            upNext,
            plants
        ]

        vc.viewControllers = [
            upNext.navigationController,
            plants.navigationController,
            settingsVC
        ]

        mainController = vc
    }

    private func showOnboarding() {
        let vc = UIViewController()
        vc.modalPresentationStyle = .fullScreen
        mainController?.present(vc, animated: true)
    }
}
