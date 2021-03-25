//
//  MainViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/28/21.
//

import UIKit

class MainViewController: UIViewController {
    lazy var timelineVC: some UIViewController = {
        let vc = TaskCalendarViewController(model: model).wrappedInNavigationController()
        vc.tabBarItem = UITabBarItem(title: "Timeline", image: UIImage(systemName: "newspaper"), selectedImage: UIImage(systemName: "newspaper.fill"))
        vc.tabBarItem.tag = 0
        return vc
    }()
    
    lazy var plantGroupVC: some UIViewController = {
        let vc = PlantGroupViewController(model: model)
        let nav = vc.wrappedInNavigationController()
        nav.tabBarItem = UITabBarItem(title: "Plants", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        nav.tabBarItem.tag = 1
        return nav
    }()
    
    lazy var plantConfigurationVC: some UIViewController = {
        let vc = PlantConfigurationViewController()
        
        return vc.wrappedInNavigationController()
    }()
    
    lazy var tabBarVC: UITabBarController = {
        let vc = UITabBarController(nibName: nil, bundle: nil)
        vc.setViewControllers([
            timelineVC,
            plantGroupVC
        ], animated: false)
        return vc
    }()
    
    #if DEBUG
    let model = GrowAppModel.preview
    #else
    let model = GrowAppModel.shared
    #endif
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        present()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        present()
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
    
