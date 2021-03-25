//
//  RoundedRectContainer.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/19/21.
//

import UIKit

class RoundedRectContainer: UIView {
    convenience init(cornerRadius: CGFloat, frame: CGRect) {
        self.init(frame: frame)
        
        self.cornerRadius = cornerRadius
        layoutMargins = UIEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius)
        backgroundColor = .systemGroupedBackground
    }
    
    var cornerRadius: CGFloat = 10.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = cornerRadius
        layer.cornerCurve = .continuous
    }
}
