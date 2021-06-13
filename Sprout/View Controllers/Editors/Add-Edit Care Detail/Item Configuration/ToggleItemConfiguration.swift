//
//  ToggleItemConfiguration.swift
//  Sprout
//
//  Created by Ryan Thally on 6/12/21.
//

import Foundation

struct ToggleItemConfiguration: Hashable {
    var text: String?
    var secondaryText: String?

    var isOn: Bool = false
    var handler: ((Bool) -> Void)?

    static func == (lhs: ToggleItemConfiguration, rhs: ToggleItemConfiguration) -> Bool {
        lhs.text == rhs.text
            && lhs.secondaryText == rhs.secondaryText
            && lhs.isOn == rhs.isOn
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(secondaryText)
        hasher.combine(isOn)
    }
}
