//
//  TappableView.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/20/21.
//

import UIKit

class IntervalPickerButton: UIButton {
    override var isSelected: Bool {
        didSet {
            updateUI()
        }
    }

    override var tintColor: UIColor! {
        didSet {
            updateUI()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = bounds.height/2
        clipsToBounds = true
    }

    private var customConstraints: (
        circleCenterX: NSLayoutConstraint,
        circleCenterY: NSLayoutConstraint,
        circleHeight: NSLayoutConstraint,
        circleWidth: NSLayoutConstraint
    )?

    private func updateUI() {
        backgroundColor = isSelected ? tintColor : .systemFill
        setTitleColor(UIColor.labelColor(against: backgroundColor), for: .normal)
    }
}
