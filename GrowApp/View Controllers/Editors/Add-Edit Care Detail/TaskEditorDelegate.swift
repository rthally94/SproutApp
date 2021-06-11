//
//  TaskEditorDelegate.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/9/21.
//

import Foundation

protocol TaskEditorDelegate: AnyObject {
    func taskEditor(_ editor: TaskEditorController, didUpdateTask task: SproutCareTaskMO)
    func taskEditorDidCancel(_ editor: TaskEditorController)
}

extension TaskEditorDelegate {
    func taskEditor(_ editor: TaskEditorController, didUpdateTask task: SproutCareTaskMO) { }
    func taskEditorDidCancel(_ editor: TaskEditorController) { }
}
