//
//  CameraOverlayView.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/22/21.
//

import UIKit

class CameraOverlayView: UIView {
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        ctx.addEllipse(in: layer.frame)
        ctx.fillPath()
    }
}
