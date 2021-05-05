//
//  MainViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/28/21.
//

import CoreData
import UIKit

class MainViewController: UIViewController {
    lazy var upNextVC: some UIViewController = {
        let vc = UpNextViewController()
        vc.persistentContainer = persistentContainer
        let nav = vc.wrappedInNavigationController()
        nav.tabBarItem = UITabBarItem(title: "Up Next", image: UIImage(systemName: "text.badge.checkmark"), tag: 0)
        return nav
    }()

    lazy var timelineVC: some UIViewController = {
        let vc = TaskCalendarViewController()
        vc.persistentContainer = persistentContainer
        let nav = vc.wrappedInNavigationController()
        nav.tabBarItem = UITabBarItem(title: "Calendar", image: UIImage(systemName: "calendar"), tag: 1)
        return nav
    }()
    
    lazy var plantGroupVC: some UIViewController = {
        let vc = PlantGroupViewController()

        let viewModel = PlantGroupViewModel()
        viewModel.persistentContainer = persistentContainer
        vc.viewModel = viewModel

        let nav = vc.wrappedInNavigationController()
        nav.tabBarItem = UITabBarItem(title: "Plants", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        nav.tabBarItem.tag = 2
        return nav
    }()
        
    lazy var tabBarVC: UITabBarController = {
        let vc = UITabBarController(nibName: nil, bundle: nil)
        vc.setViewControllers([
            upNextVC,
            plantGroupVC
        ], animated: false)
        return vc
    }()
    
    var persistentContainer: NSPersistentContainer = AppDelegate.persistentContainer

    override func viewDidLoad() {
        super.viewDidLoad()
        present()
    }
    
    private func present() {
        addChild(tabBarVC)
        view.addSubview(tabBarVC.view)
        didMove(toParent: self)
    }
}

extension UIViewController {
    func wrappedInNavigationController() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }
}
    
