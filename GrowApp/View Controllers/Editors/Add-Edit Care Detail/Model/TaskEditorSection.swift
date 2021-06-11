//
//  TaskEditorSection.swift
//  Sprout
//
//  Created by Ryan Thally on 6/10/21.
//

import Foundation

struct TaskEditorSection: Identifiable, Hashable {
    enum Identifier: String, CaseIterable {
        case detailHeader
        case scheduleGeneral
        case recurrenceFrequency
        case recurrenceValue
    }

    var id: Identifier

    var items: [TaskEditorItem.ID]

    var headerText: String?
    var showsHeader: Bool {
        headerText != nil
    }

    var footerText: String?
    var showsFooter: Bool {
        footerText != nil
    }
    
    init(id: Identifier, items: [TaskEditorItem.ID], headerText: String? = nil, footerText: String? = nil) {
        self.id = id
        self.items = items
        self.headerText = headerText
        self.footerText = footerText
    }
}
