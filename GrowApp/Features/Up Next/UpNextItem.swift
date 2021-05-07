//
//  UpNextItem.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/6/21.
//

import Foundation

struct UpNextItem: Hashable {
    var task: GHTask

    var title: String? {
        return task.plant?.name
    }

    var subtitle: String? {
        return task.interval?.intervalText()
    }

    var icon: GHIcon? {
        return task.plant?.icon
    }

    var isChecked: Bool {
        guard let lastLogDate = task.lastLogDate, let nextCareDate = task.nextCareDate else { return false }
        return Calendar.current.startOfDay(for: lastLogDate) == Calendar.current.startOfDay(for: nextCareDate)
    }

    // MARK: - Task Actions
    func markAsComplete() {
        task.markAsComplete()
    }
}
