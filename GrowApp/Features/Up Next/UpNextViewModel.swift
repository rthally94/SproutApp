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

    let headerDateFormatter = Utility.relativeDateFormatter

    private lazy var tasksProvider = TasksProvider(managedObjectContext: persistentContainer.viewContext)
    var persistentContainer = AppDelegate.persistentContainer

    var snapshot: AnyPublisher<Snapshot, Never> {
        tasksProvider.$snapshot
            .map { snapshot in
                var newSnapshot = Snapshot()
                if let oldSnapshot = snapshot {
                    let sections: [Section] = oldSnapshot.sectionIdentifiers.compactMap {
                        guard let date = self.stringToDateFormatter.date(from: $0) else { return nil }
                        return Section(title: self.headerDateFormatter.string(from: date))
                    }
                    newSnapshot.appendSections(sections)

                    zip(oldSnapshot.sectionIdentifiers, newSnapshot.sectionIdentifiers).forEach { oldSection, newSection in
                        let taskIDs = oldSnapshot.itemIdentifiers(inSection: oldSection)
                        var items = [Item]()
                        var itemsToReload = [Item]()

                        taskIDs.forEach { taskID in
                            if let task = self.tasksProvider.object(withID: taskID) as? GHTask,
                               let plantID = task.plant?.objectID,
                               let plant = self.tasksProvider.object(withID: plantID) as? GHPlant {
                                let item = Item(task: task, plant: plant)
                                items.append(item)
                                if task.isUpdated {
                                    itemsToReload.append(item)
                                }
                            }
                        }

                        newSnapshot.appendItems(items)
                        newSnapshot.reloadItems(itemsToReload)
                    }
                }
                return newSnapshot
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Task Methods
    func markTaskAsComplete(_ task: GHTask) {
        task.markAsComplete()
    }
}