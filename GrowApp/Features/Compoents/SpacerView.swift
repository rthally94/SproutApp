//
//  SpacerView.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/10/21.
//

import UIKit

class SpacerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
    }
}
