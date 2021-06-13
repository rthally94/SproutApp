//
//  TaskEditorSection.swift
//  Sprout
//
//  Created by Ryan Thally on 6/10/21.
//

import Foundation

enum TaskEditorSection: Hashable {
    case detailHeader(SectionConfiguration)
    case scheduleGeneral(SectionConfiguration)
    case recurrenceFrequency(SectionConfiguration)
    case recurrenceValue(SectionConfiguration)
}

extension TaskEditorSection {
    func configuration() -> SectionConfiguration {
        switch self {
        case let .detailHeader(config):
            return config
        case let .scheduleGeneral(config):
            return config
        case let .recurrenceFrequency(config):
            return config
        case let .recurrenceValue(config):
            return config
        }
    }
}
