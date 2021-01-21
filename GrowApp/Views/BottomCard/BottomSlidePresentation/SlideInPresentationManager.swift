//
//  SlideInPresentationManager.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/20/21.
//

import UIKit

enum PresentationDirection {
    case left
    case top
    case right
    case bottom
}

class SlideInPresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    var direction: PresentationDirection = .bottom
}
