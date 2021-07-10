//
//  CareHistoryConfiguration.swift
//  Sprout
//
//  Created by Ryan Thally on 7/10/21.
//

import UIKit
import SproutKit

struct CareHistoryConfiguration {
    let status: SproutMarkStatus?
    let statusDate: Date?

    var icon: UIImage? {
        switch status {
        case .done:
            return UIImage(systemName: "checkmark.circle.fill")
        case .due:
            return UIImage(systemName: "circle")
        case .late:
            return UIImage(systemName: "xmark.circle.fill")
        case .skipped:
            return UIImage(systemName: "arrowshape.turn.up.right.circle.fill")
        default:
            return nil
        }
    }
}

extension CareHistoryConfiguration {
    init(task: SproutCareTaskMO) {
        self.init(status: task.markStatus, statusDate: task.statusDate)
    }
}

extension CareHistoryConfiguration: Hashable { }
