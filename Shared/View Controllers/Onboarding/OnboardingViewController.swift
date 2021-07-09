//
//  OnboardingHostingController.swift
//  Sprout
//
//  Created by Ryan Thally on 7/7/21.
//

import SwiftUI

final class OnboardingViewController: UIViewController {
    weak var coordinator: MainCoordinator?
    private lazy var contentController: UIViewController = UIHostingController(rootView: OnboardingContainerView(isVisible: isVisible))
    
    private var _isVisible: Bool = true
    var isVisible: Binding<Bool> {
        Binding<Bool> {[weak self] in
            self?._isVisible ?? false
        } set: {[weak self] newValue in
            guard let self = self else { return }
            self._isVisible = newValue
            if !newValue {
                self.coordinator?.onboardingViewController(self, didFinishWithStatus: .finished)
            }
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(contentController)
        contentController.view.frame = view.frame
        view.addSubview(contentController.view)
        contentController.didMove(toParent: self)
    }
}

