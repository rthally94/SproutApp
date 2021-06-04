//
//  UpNextItem.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/6/21.
//

import CoreData
import UIKit

struct UpNextItem: Hashable {
    static let reloadInterval = 2.0
    let scheduleFormatter = Utility.careScheduleFormatter

    var task: SproutCareTaskMO
    var plant: SproutPlantMO

    var title: String? {
        return plant.primaryDisplayName
    }

    var subtitle: String? {
        if let schedule = task.schedule {
            return scheduleFormatter.string(from: schedule)
        } else {
            return nil
        }
    }

    var icon: UIImage? {
        return plant.icon
    }

    var daysLate: Int? {
        guard task.hasSchedule == false,
              let dueDate = task.dueDate,
              let daysLate = Calendar.current.dateComponents([.day], from: dueDate, to: Date()).day
        else { return nil }

        return daysLate < 0 ? 0 : daysLate
    }

    var isChecked: Bool {
        task.historyLog != nil
    }

    // MARK: - Task Actions
    func markAsComplete() {
        do {
            try task.markAs(.complete) {
                do {
                    if task.managedObjectContext?.hasChanges == true {
                        try task.managedObjectContext?.save()
                    }
                } catch {
                    print("Error saving context: \(error)")
                    task.managedObjectContext?.rollback()
                }
            }
        } catch {
            print("Error marking task as complete: \(error)")
        }
    }
}

extension UpNextItem {
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(subtitle)
        hasher.combine(isChecked)
        hasher.combine(icon)
        hasher.combine(daysLate)
        hasher.combine(plant.id)
        hasher.combine(task.id)
    }

    static func ==(lhs: UpNextItem, rhs: UpNextItem) -> Bool {
        lhs.title == rhs.title
            && lhs.subtitle == rhs.subtitle
            && lhs.isChecked == rhs.isChecked
            && lhs.icon == rhs.icon
            && lhs.daysLate == rhs.daysLate
            && lhs.plant.id == rhs.plant.id
            && lhs.task.id == rhs.task.id
    }
}
