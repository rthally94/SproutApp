//
//  LogEntrty.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/15/21.
//

import Foundation

enum LogState: String, Hashable {
    case complete
    case skipped
}

class LogEntry: Hashable {
    static func == (lhs: LogEntry, rhs: LogEntry) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var id: UUID
    var task: Task?
    var state: LogState
    var date: Date
    
    internal init(id: UUID, task: Task, state: LogState, date: Date) {
        self.id = id
        self.task = task
        self.state = state
        self.date = date
    }
}
