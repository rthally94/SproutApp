//
//  SproutIntervalFormatter.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/11/21.
//

import Foundation

class SproutIntervalFormatter: Formatter {
    enum Style {
        case none, short, medium, long, full
    }

    var frequencyStyle: Style = .none
    var valuesStyle: Style = .none
    var formattingContext: Context = .dynamic

    override func string(for obj: Any?) -> String? {
        guard let obj = obj as? CareRecurrenceRule else { return nil }
        return string(for: obj)
    }

    func string(for interval: CareRecurrenceRule) -> String {
        return ""
    }
}
