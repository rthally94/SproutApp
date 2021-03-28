//
//  UIView+Extension.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/3/21.
//

import UIKit

extension UIView {
    func pinToBoundsOf(_ parent: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: parent.topAnchor),
            self.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
        ])
    }
    
    func pinToLayoutMarginsOf(_ parent: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: parent.layoutMarginsGuide.topAnchor),
            self.leadingAnchor.constraint(equalTo: parent.layoutMarginsGuide.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: parent.layoutMarginsGuide.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: parent.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    func safePinToLayoutMarginsOf(_ parent: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let safeTopConstraint = self.topAnchor.constraint(equalTo: parent.layoutMarginsGuide.topAnchor)
        safeTopConstraint.priority = .required - 1
        
        let safeLeadingConstraint = self.leadingAnchor.constraint(equalTo: parent.layoutMarginsGuide.leadingAnchor)
        safeLeadingConstraint.priority = .required - 1
        
        NSLayoutConstraint.activate([
            safeTopConstraint,
            safeLeadingConstraint,
            self.bottomAnchor.constraint(equalTo: parent.layoutMarginsGuide.bottomAnchor),
            self.trailingAnchor.constraint(equalTo: parent.layoutMarginsGuide.trailingAnchor)
        ])
    }
}
