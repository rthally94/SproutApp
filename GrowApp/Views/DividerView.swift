//
//  DividerView.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/18/21.
//

import UIKit

class DividerView: UIView {
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.width/2, y: 0))
        path.addLine(to: CGPoint(x: rect.width/2, y: rect.height))
        UIColor.systemGray.setStroke()
        path.stroke()
    }
}
