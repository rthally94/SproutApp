//
//  TextFieldConfiguration.swift
//  Sprout
//
//  Created by Ryan Thally on 6/11/21.
//

import UIKit

struct TextFieldItemConfiguration: Hashable {
    var placeholder: String?
    var initialText: String?
    var handler: ((String?) -> Void)?

    func hash(into hasher: inout Hasher) {
        hasher.combine(placeholder)
        hasher.combine(initialText)
    }

    static func == (lhs: TextFieldItemConfiguration, rhs: TextFieldItemConfiguration) -> Bool {
        return lhs.placeholder == rhs.placeholder
            && lhs.initialText == rhs.initialText
    }
}
