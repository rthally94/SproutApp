//
//  Coordinator.swift
//  Sprout
//
//  Created by Ryan Thally on 6/29/21.
//

import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
}
