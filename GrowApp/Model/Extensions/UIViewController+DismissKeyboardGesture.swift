//
//  UIViewController+DismissKeyboardGesture.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/28/21.
//

import UIKit

extension UIViewController {
    func dismissKeyboardWhenTappedOutside() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
