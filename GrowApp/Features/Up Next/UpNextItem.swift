//
//  UpNextItem.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/6/21.
//

import Foundation

struct UpNextItem: Hashable {
    var careInfo: CareInfo
    var plant: GHPlant

    var title: String? {
        return plant.name
    }

    var subtitle: String? {
        return careInfo.careSchedule?.recurrenceRule?.intervalText()
    }

    var icon: SproutIcon? {
        return plant.icon
    }

    var daysLate: Int? {
        guard let lastLogDate = careInfo.lastLogDate,
              let nextCareDate = careInfo.nextCareDate,
              let daysLate = Calendar.current.dateComponents([.day], from: nextCareDate, to: lastLogDate).day
        else { return nil }

        return daysLate < 0 ? 0 : daysLate
    }

    var isChecked: Bool {
        guard let lastLogDate = careInfo.lastLogDate, let nextCareDate = careInfo.nextCareDate else { return false }
        return Calendar.current.startOfDay(for: lastLogDate) == Calendar.current.startOfDay(for: nextCareDate)
    }

    // MARK: - Task Actions
    func markAsComplete() {
        careInfo.markAsComplete()
    }
}
