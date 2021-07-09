//
//  SproutTabBarController.swift
//  Sprout
//
//  Created by Ryan Thally on 6/29/21.
//

import UIKit
import SwiftUI

class SproutTabBarController: UITabBarController {
    weak var coordinator: MainCoordinator?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !UserDefaults.standard.hasLaunched {
            coordinator?.showOnboarding()
        }
    }
}
