//
//  MainViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/28/21.
//

import CoreData
import SwiftUI
import UIKit

class MainViewController: UIViewController {
    var plantsNeedingCare: Int {
        return 1
    }

    lazy var upNextVC: some UIViewController = { [unowned self] in
        let vc = UpNextViewController()

        let nav = vc.wrappedInNavigationController()
        nav.navigationBar.prefersLargeTitles = true

        nav.tabBarItem = UITabBarItem(title: "Up Next", image: UIImage(systemName: "text.badge.checkmark"), tag: 0)
        if plantsNeedingCare > 0 {
            //            nav.tabBarItem.badgeValue = "\(plantsNeedingCare)"
            nav.tabBarItem.badgeColor = UIColor.systemGreen
        }
        return nav
    }()
    
    lazy var plantGroupVC: some UIViewController = {
        let vc = PlantGroupViewController()

        let nav = vc.wrappedInNavigationController()
        nav.navigationBar.prefersLargeTitles = true
        
        nav.tabBarItem = UITabBarItem(title: "Plants", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        nav.tabBarItem.tag = 2
        return nav
    }()

    lazy var settingsVC: some UIViewController = {
        let view = SettingsView()
        let hostedView = UIHostingController(rootView: view)
        hostedView.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), selectedImage: UIImage(systemName: "gear"))
        hostedView.tabBarItem.tag = 3
        return hostedView
    }()

    lazy var tabBarVC: UITabBarController = { [unowned self] in
        let vc = UITabBarController(nibName: nil, bundle: nil)
        vc.setViewControllers([
            upNextVC,
            plantGroupVC,
            settingsVC
        ], animated: false)
        return vc
    }()
    
    var persistentContainer: NSPersistentContainer = AppDelegate.persistentContainer

    override func viewDidLoad() {
        super.viewDidLoad()
        present()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let isFirstLaunch = !UserDefaults.standard.hasLaunched
        if isFirstLaunch {
            showInitialConfiguration()
        }
    }
    
    private func present() {
        addChild(tabBarVC)
        view.addSubview(tabBarVC.view)
        didMove(toParent: self)
    }

    private func showInitialConfiguration() {
        let alertController = UIAlertController(title: "Load Sample Data", message: "Would you like to load sample data to demonstrate application functionality?", preferredStyle: .alert)

        let loadSampleDataAction = UIAlertAction(title: "Load Data", style: .default, handler: { sender in
            AppDelegate.storageProvider.loadSampleData()
            UserDefaults.standard.hasLaunched = true
        })

        let skipConfigAction = UIAlertAction(title: "Skip Setup", style: .cancel, handler: { sender in
            UserDefaults.standard.hasLaunched = true
        })

        alertController.addAction(skipConfigAction)
        alertController.addAction(loadSampleDataAction)

        present(alertController, animated: true)
    }
}

extension UIViewController {
    func wrappedInNavigationController() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }
}

