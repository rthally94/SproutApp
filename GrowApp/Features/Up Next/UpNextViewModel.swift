//
//  UpNextViewModel.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/6/21.
//

import Combine
import CoreData
import UIKit

class UpNextViewModel {
    typealias Section = UpNextSection
    typealias Item = UpNextItem
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    let stringToDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZ"
        return formatter
    }()

    let relativeDateFormatter = Utility.relativeDateFormatter

    let headerDateFormatter = Utility.relativeDateFormatter

    private lazy var tasksProvider = AllTasksProvider(managedObjectContext: persistentContainer.viewContext)
    var persistentContainer = AppDelegate.persistentContainer

    var snapshot: AnyPublisher<Snapshot, Never> {
        tasksProvider.$scheduledReminders
            .combineLatest(tasksProvider.$unscheduledReminders)
            .map { scheduledReminders, unscheduledReminders in
                var upNextSnapshot = Snapshot()

                if let scheduledReminders = scheduledReminders {
                    let sortedDates = scheduledReminders.keys.sorted()
                    sortedDates.forEach { date in
                        let section = Section.scheduled(date)
                        upNextSnapshot.appendSections([section])
                        let items = scheduledReminders[date]!.compactMap({ task -> Item? in
                            guard let plant = task.plant else { return nil }
                            return Item(task: task, plant: plant)
                        })
                        upNextSnapshot.appendItems(items, toSection: section)
                    }
                }

                if let unscheduledReminders = unscheduledReminders {
                    upNextSnapshot.appendSections([.unscheduled])
                    let items = unscheduledReminders.compactMap { task -> Item? in
                        guard let plant = task.plant else { return nil }
                        return Item(task: task, plant: plant)
                    }
                    upNextSnapshot.appendItems(items, toSection: .unscheduled)
                }

                return upNextSnapshot
            }
            .eraseToAnyPublisher()
    }

    var tasksNeedingCare: AnyPublisher<Int, Never> {
        snapshot
            .map {
                $0.itemIdentifiers.reduce(0) { result, item in
                    result + (item.isChecked ? 0 : 1)
                }
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Task Methods
    func markItemAsComplete(_ item: UpNextItem) {
        item.markAsComplete()
        persistentContainer.saveContextIfNeeded()
    }
}
