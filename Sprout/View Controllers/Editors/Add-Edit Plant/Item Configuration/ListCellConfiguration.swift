//
//  ListCellConfiguration.swift
//  Sprout
//
//  Created by Ryan Thally on 6/12/21.
//

import UIKit

struct ListCellConfiguration: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(cellStyle)
        hasher.combine(image)
        hasher.combine(preferredSymbolConfiguration)
        hasher.combine(text)
        hasher.combine(secondaryText)
    }

    static func == (lhs: ListCellConfiguration, rhs: ListCellConfiguration) -> Bool {
        lhs.cellStyle == rhs.cellStyle
            && lhs.image == rhs.image
            && lhs.preferredSymbolConfiguration == rhs.preferredSymbolConfiguration
            && lhs.text == rhs.text
            && lhs.secondaryText == rhs.secondaryText
    }

    var cellStyle: CellStyle = .plain

    var image: UIImage?
    var preferredSymbolConfiguration: UIImage.SymbolConfiguration?

    var text: String?
    var secondaryText: String?

    var accessories: [UICellAccessory]?

    var handler: (() -> Void)?

    var title: String? {
        get { text }
        set { text = newValue }
    }

    var subtitle: String? {
        get { secondaryText }
        set { secondaryText = newValue }
    }

    var value: String? {
        get { secondaryText }
        set { secondaryText = newValue }
    }

    init() {}
}

extension ListCellConfiguration {
    enum CellStyle: Hashable {
        case plain
        case value
        case subtitle
    }
}

extension ListCellConfiguration {
    static func plain() -> ListCellConfiguration {
        return ListCellConfiguration()
    }

    static func value() -> ListCellConfiguration {
        var config = ListCellConfiguration()
        config.cellStyle = .value
        return config
    }

    static func subtitle() -> ListCellConfiguration {
        var config = ListCellConfiguration()
        config.cellStyle = .subtitle
        return config
    }
}

extension ListCellConfiguration {
    func contentConfiguration() -> UIListContentConfiguration {
        var config: UIListContentConfiguration
        switch cellStyle {
        case .plain:
            config = UIListContentConfiguration.cell()
        case .value:
            config = UIListContentConfiguration.valueCell()
        case .subtitle:
            config = UIListContentConfiguration.subtitleCell()
        }

        config.text = text
        config.secondaryText = text

        config.image = image
        config.imageProperties.preferredSymbolConfiguration = preferredSymbolConfiguration

        return config
    }
}
