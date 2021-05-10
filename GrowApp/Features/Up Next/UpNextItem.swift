//
//  UpNextItem.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/6/21.
//

import Foundation

struct UpNextItem: Hashable {
    var task: GHTask
    var plant: GHPlant

    var title: String? {
        return plant.name
    }

    var subtitle: String? {
        return task.interval?.intervalText()
    }

    var icon: GHIcon? {
        return plant.icon
    }

    var daysLate: Int? {
        guard let lastLogDate = task.lastLogDate,
              let nextCareDate = task.nextCareDate,
              let daysLate = Calendar.current.dateComponents([.day], from: nextCareDate, to: lastLogDate).day
        else { return nil }

        return daysLate < 0 ? 0 : daysLate
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