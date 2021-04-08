//
//  MainViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/28/21.
//

import CoreData
import UIKit

class MainViewController: UIViewController {
    lazy var timelineVC: some UIViewController = {
        let vc = TaskCalendarViewController(viewContext: viewContext).wrappedInNavigationController()
        vc.tabBarItem = UITabBarItem(title: "Calendar", image: UIImage(systemName: "calendar"), selectedImage: UIImage(systemName: "calendar"))
        vc.tabBarItem.tag = 0
        return vc
    }()
    
    lazy var plantGroupVC: some UIViewController = {
        let vc = PlantGroupViewController(viewContext: viewContext, model: model)
        let nav = vc.wrappedInNavigationController()
        nav.tabBarItem = UITabBarItem(title: "Plants", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        nav.tabBarItem.tag = 1
        return nav
    }()
        
    lazy var tabBarVC: UITabBarController = {
        let vc = UITabBarController(nibName: nil, bundle: nil)
        vc.setViewControllers([
            timelineVC,
            plantGroupVC
        ], animated: false)
        return vc
    }()
    
    var viewContext: NSManagedObjectContext
    #if DEBUG
    let model = GreenHouseAppModel.preview
    #else
    let model = GrowAppModel.shared
    #endif
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
     
        super.init(nibName: nil, bundle: nil)
        
        present()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func present() {
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
    
