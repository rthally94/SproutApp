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

    private lazy var tasksProvider = TasksProvider(managedObjectContext: persistentContainer.viewContext)
    var persistentContainer = AppDelegate.persistentContainer

    var snapshot: AnyPublisher<Snapshot, Never> {
        tasksProvider.$snapshot
            .map { snapshot in
                var newSnapshot = Snapshot()
                if let oldSnapshot = snapshot {
                    let midnightToday = Calendar.current.startOfDay(for: Date())
                    let sections: [Section] = oldSnapshot.sectionIdentifiers.reduce(into: [Section]()) { sections, sectionIdentifier in
                        if let date = self.stringToDateFormatter.date(from: sectionIdentifier), date >= midnightToday {
                            let dateString = self.relativeDateFormatter.string(from: date)
                            sections.append(Section(title: dateString))
                        } else {
                            print("Unable to extract date from: \(sectionIdentifier)")
                            sections.append(Section(title: sectionIdentifier))
                        }
                    }
                    newSnapshot.appendSections(sections)

                    zip(oldSnapshot.sectionIdentifiers, newSnapshot.sectionIdentifiers).forEach { oldSection, newSection in
                        let taskIDs = oldSnapshot.itemIdentifiers(inSection: oldSection)
                        var items = [Item]()
                        var itemsToReload = [Item]()

                        taskIDs.forEach { taskID in
                            if let reminder = self.tasksProvider.object(withID: taskID) as? SproutReminder,
                               let careInfoID = reminder.careInfo?.objectID,
                               let careInfo = self.tasksProvider.object(withID: careInfoID) as? CareInfo,
                               let plantID = reminder.careInfo?.plant?.objectID,
                               let plant = self.tasksProvider.object(withID: plantID) as? GHPlant
                            {
                                let item = Item(careInfo: careInfo, plant: plant)
                                items.append(item)
                                if reminder.isUpdated {
                                    itemsToReload.append(item)
                                }
                            }
                        }

                        if let date = self.stringToDateFormatter.date(from: oldSection), date < midnightToday {
                            let midnightTodayString = self.relativeDateFormatter.string(from: midnightToday)
                            let todaySection = newSnapshot.sectionIdentifiers.first(where: { $0.title == midnightTodayString })
                            newSnapshot.appendItems(items, toSection: todaySection)
                        } else {
                            newSnapshot.appendItems(items, toSection: newSection)
                        }
                        newSnapshot.reloadItems(itemsToReload)
                    }
                }
                return newSnapshot
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
