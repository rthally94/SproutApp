//
//  TaskEditorDelegate.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/9/21.
//

import Foundation
import SproutKit

protocol TaskEditorDelegate: AnyObject {
    func taskEditor(_ editor: TaskEditorViewController, didUpdateTask task: SproutCareTaskMO)
    func taskEditorDidCancel(_ editor: TaskEditorViewController)
}

extension TaskEditorDelegate {
    func taskEditor(_: TaskEditorViewController, didUpdateTask _: SproutCareTaskMO) {}
    func taskEditorDidCancel(_: TaskEditorViewController) {}
}
