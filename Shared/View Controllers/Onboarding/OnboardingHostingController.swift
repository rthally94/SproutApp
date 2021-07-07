//
//  OnboardingHostingController.swift
//  Sprout
//
//  Created by Ryan Thally on 7/7/21.
//

import SwiftUI

final class OnboardingViewController: UIViewController {
    weak var coordinator: MainCoordinator?
    let contentController: UIViewController = UIHostingController(rootView: OnboardingContainerView())

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(contentController)
        view.addSubview(contentController.view)
        contentController.didMove(toParent: self)
    }
}

