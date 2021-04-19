//
//  TaskEditorDelegate.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/9/21.
//

import Foundation

protocol TaskEditorDelegate {
    func taskEditor(_ editor: TaskEditorController, didUpdateTask task: GHTask)
    func taskEditorDidCancel(_ editor: TaskEditorController)
}

extension TaskEditorDelegate {
    func taskEditor(_ editor: TaskEditorController, didUpdateTask task: GHTask) { }
    func taskEditorDidCancel(_ editor: TaskEditorController) { }
}
