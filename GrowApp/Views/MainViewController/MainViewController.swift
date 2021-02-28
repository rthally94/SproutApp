//
//  MainViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/28/21.
//

import UIKit

class MainViewController: UIViewController {
    lazy var timelineVC: some UIViewController = {
        let vc = TimelineViewController(nibName: nil, bundle: nil).wrappedInNavigationController()
        vc.tabBarItem = UITabBarItem(title: "Timeline", image: UIImage(systemName: "newspaper"), selectedImage: UIImage(systemName: "newspaper.fill"))
        return vc
    }()
    
    lazy var plantGroupVC: some UIViewController = {
        let vc = PlantGroupViewController().wrappedInNavigationController()
        vc.tabBarItem = UITabBarItem(title: "Plants", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        return vc
    }()
    
    lazy var tabBarVC: UITabBarController = {
        let vc = UITabBarController(nibName: nil, bundle: nil)
        vc.setViewControllers([
            timelineVC,
            plantGroupVC
        ], animated: false)
        return vc
    }()
    
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
    
