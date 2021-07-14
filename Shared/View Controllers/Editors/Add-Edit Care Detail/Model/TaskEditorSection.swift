//
//  TaskEditorSection.swift
//  Sprout
//
//  Created by Ryan Thally on 6/10/21.
//

import Foundation

struct TaskEditorSection {
    let id: UUID
    var header: String?
    var footer: String?
    var layout: Layout
    var children: [TaskEditorItem]

    var showsHeader: Bool {
        header != nil
    }

    var showsFooter: Bool {
        footer != nil
    }

    enum Layout: Hashable {
        case header
        case list
    }
}

extension TaskEditorSection: Hashable {
    static func ==(lhs: TaskEditorSection, rhs: TaskEditorSection) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension TaskEditorSection {
    init(header: String? = nil, footer: String? = nil, layout: Layout, children: [TaskEditorItem]) {
        self.init(id: UUID(), header: header, footer: footer, layout: layout, children: children)
    }
}
