//
//  CapsuleButton.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/21/21.
//

import UIKit

class CapsuleButton: UIButton {
    private var configured = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !configured {
            contentEdgeInsets = UIEdgeInsets(top: 20, left: 30, bottom: 20, right: 30)
            
            layer.cornerRadius = bounds.height/2
            layer.cornerCurve = .continuous
            
            imageView?.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .headline)
            titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
            
            if backgroundColor == nil {
                backgroundColor = .systemGreen
            }
            
            tintColor = UIColor.labelColor(against: backgroundColor).withAlphaComponent(0.8)
            configured = true
        }
    }
}
