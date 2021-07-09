//
//  Presentable.swift
//  Sprout
//
//  Created by Ryan Thally on 7/7/21.
//

import UIKit

protocol WelcomePresentable {
    func viewController(_ viewController: UIViewController, didFinishWithStatus: DismissStatus)
}
