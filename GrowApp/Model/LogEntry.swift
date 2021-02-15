//
//  LogEntrty.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/15/21.
//

import Foundation

enum LogState: String {
    case complete
    case skipped
}

class LogEntry {
    var id: UUID
    weak var task: Task?
    var state: LogState
    var date: Date
    
    internal init(id: UUID, task: Task, state: LogState, date: Date) {
        self.id = id
        self.task = task
        self.state = state
        self.date = date
    }
}
