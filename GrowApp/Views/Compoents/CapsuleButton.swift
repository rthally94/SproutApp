//
//  CapsuleButton.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/21/21.
//

import UIKit

class CapsuleButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        
        contentEdgeInsets = UIEdgeInsets(top: 20, left: 30, bottom: 20, right: 30)
        
        backgroundColor = .systemBlue
        layer.cornerRadius = bounds.height/2
        layer.cornerCurve = .continuous
    }
}
