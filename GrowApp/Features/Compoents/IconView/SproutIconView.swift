//
//  SproutIcon.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/16/21.
//

import UIKit

class SproutIconView: IconView {
    var icon: GHIcon? {
        didSet {
            populateIconProperties()
        }
    }

    private func populateIconProperties() {
        var config = defaultConfiguration()
        config.image = icon?.image
        config.tintColor = icon?.color
        configuration = config
    }
}
