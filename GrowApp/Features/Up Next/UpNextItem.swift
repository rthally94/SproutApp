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
    let dateFormatter = Utility.dateFormatter

    var task: SproutCareTaskMO
    var plant: SproutPlantMO

    var title: String? {
        return plant.nickname ?? plant.commonName
    }

    var subtitle: String? {
        if let date = task.dueDate {
            return dateFormatter.string(from: date)
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
                    try task.managedObjectContext?.save()
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
