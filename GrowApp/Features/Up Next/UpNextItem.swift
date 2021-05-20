//
//  UpNextItem.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/6/21.
//

import CoreData

struct UpNextItem: Hashable {
    static let reloadInterval = 2.0
    let scheduleFormatter = Utility.currentScheduleFormatter

    var careInfo: CareInfo
    var plant: GHPlant

    var title: String? {
        return plant.name
    }

    var subtitle: String? {
        return scheduleFormatter.string(for: careInfo.nextReminder.schedule)
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
        if let secondsSinceLastLog = Calendar.current.dateComponents([.second], from: Date(), to: lastLogDate).second, Double(secondsSinceLastLog) < Self.reloadInterval {
            return true
        } else {
            return Calendar.current.startOfDay(for: lastLogDate) == Calendar.current.startOfDay(for: nextCareDate)
        }
    }

    // MARK: - Task Actions
    func markAsComplete() {
        careInfo.markAsComplete()
    }
}
