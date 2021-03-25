//
//  Circle.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/18/21.
//

import UIKit

class Circle: UIView {
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.addEllipse(in: rect)
        ctx?.setFillColor(tintColor.cgColor)
        ctx?.fillPath()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundColor = .clear
    }
}
