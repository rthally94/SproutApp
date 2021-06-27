//
//  UpNextItem.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/6/21.
//

import CoreData
import UIKit
import SproutKit

struct UpNextItem: Hashable {
    static let reloadInterval = 2.0
    let scheduleFormatter = Utility.careScheduleFormatter

    var task: SproutCareTaskMO
    var plant: SproutPlantMO

    var title: String? {
        return plant.primaryDisplayName
    }

    var subtitle: String? {
        task.careInformation?.type?.capitalized
    }

    var schedule: String? {
        guard let schedule = task.schedule else { return nil }

        switch task.recurrenceRule {
        case .daily:
            scheduleFormatter.frequencyStyle = .none
            return "Every " + scheduleFormatter.string(from: schedule)
        default:
            scheduleFormatter.frequencyStyle = .short
            return scheduleFormatter.string(from: schedule)
        }
    }

    var plantIcon: UIImage? {
        return plant.getImage() ?? UIImage.PlaceholderPlantImage
    }

    var scheduleIcon: UIImage? {
        return task.hasSchedule ? UIImage(systemName: "bell.fill") : UIImage(systemName: "bell.slash")
    }

    var isChecked: Bool {
        task.markStatus == .done
    }

    // MARK: - Task Actions
    func markAsComplete() {
        task.markAsComplete()
    }
}

extension UpNextItem {
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(subtitle)
        hasher.combine(isChecked)
        hasher.combine(plantIcon)
        hasher.combine(schedule)
        hasher.combine(plant.id)
        hasher.combine(task.id)
    }

    static func ==(lhs: UpNextItem, rhs: UpNextItem) -> Bool {
        lhs.title == rhs.title
            && lhs.subtitle == rhs.subtitle
            && lhs.isChecked == rhs.isChecked
            && lhs.plantIcon == rhs.plantIcon
            && lhs.schedule == rhs.schedule
            && lhs.plant.id == rhs.plant.id
            && lhs.task.id == rhs.task.id
    }
}
