//
//  MainViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/28/21.
//

import UIKit

class MainViewController: UIViewController {
    lazy var timelineVC: TimelineViewController = {
        let vc = TimelineViewController(nibName: nil, bundle: nil)
        return vc
    }()
    
    lazy var tabBarVC: UITabBarController = {
        let vc = UITabBarController(nibName: nil, bundle: nil)
        vc.setViewControllers([
            timelineVC.wrappedInNavigationController(),
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
    
