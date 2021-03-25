//
//  RoundedRect.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/18/21.
//

import UIKit

class RoundedRect: UIView {
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 16)
        ctx?.addPath(path.cgPath)
        ctx?.setFillColor(tintColor.cgColor)
        ctx?.fillPath()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundColor = .clear
    }
}
