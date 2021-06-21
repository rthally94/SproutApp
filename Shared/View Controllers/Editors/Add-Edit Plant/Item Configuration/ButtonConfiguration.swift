//
//  ButtonConfiguration.swift
//  Sprout
//
//  Created by Ryan Thally on 6/12/21.
//

import UIKit

struct ButtonConfiguration: Hashable {
    var role: ButtonRole = .plain

    var title: String?
    var image: UIImage?
    var preferredSymbolConfiguration: UIImage.SymbolConfiguration?

    var tintColor: UIColor?

    var handler: (() -> Void)?

    init() {}

    func hash(into hasher: inout Hasher) {
        hasher.combine(role)
        hasher.combine(title)
        hasher.combine(image)
        hasher.combine(preferredSymbolConfiguration)
        hasher.combine(tintColor)
    }

    static func == (lhs: ButtonConfiguration, rhs: ButtonConfiguration) -> Bool {
        lhs.role == rhs.role
            && lhs.title == rhs.title
            && lhs.image == rhs.image
            && lhs.preferredSymbolConfiguration == rhs.preferredSymbolConfiguration
            && lhs.tintColor == rhs.tintColor
    }
}

extension ButtonConfiguration {
    enum ButtonRole: Hashable {
        case plain
        case normal
        case filled
        case destructive
    }
}

extension ButtonConfiguration {
    static func plain() -> ButtonConfiguration {
        ButtonConfiguration()
    }

    static func normal() -> ButtonConfiguration {
        var config = ButtonConfiguration()
        config.role = .normal
        return config
    }

    static func filled() -> ButtonConfiguration {
        var config = ButtonConfiguration()
        config.role = .filled
        return config
    }
}
