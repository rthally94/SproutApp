//
//  UpNextViewModel.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/6/21.
//

import Combine
import CoreData
import UIKit
import SproutKit

class UpNextViewModel {
    typealias Section = String
    typealias Item = NSManagedObjectID
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    let stringToDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZ"
        return formatter
    }()

    let relativeDateFormatter = Utility.relativeDateFormatter
    let headerDateFormatter = Utility.relativeDateFormatter

    @Published private(set) var doesShowAllCompletedTasks = true
    @Published private(set) var taskMarkerDate: Date = Date()

    private lazy var tasksProvider = UpNextProvider(managedObjectContext: persistentContainer.viewContext)
    var persistentContainer = AppDelegate.persistentContainer

    var snapshot: AnyPublisher<Snapshot?, Never> {
        tasksProvider.$snapshot
            .map { oldSnapshot in
                var newSnapshot = Snapshot()

                oldSnapshot?.sectionIdentifiers.forEach({ section in
                    if let sectionDate = self.stringToDateFormatter.date(from: section) {
                        let newSectionDate = Calendar.current.startOfDay(for: sectionDate)
                        let newSectionDateFormatted = self.stringToDateFormatter.string(from: newSectionDate)
                        if !newSnapshot.sectionIdentifiers.contains(newSectionDateFormatted) {
                            newSnapshot.appendSections([newSectionDateFormatted])
                        }
                        
                        let items = oldSnapshot?.itemIdentifiers(inSection: section) ?? []
                        newSnapshot.appendItems(items, toSection: newSectionDateFormatted)
                    } else {
                        newSnapshot.appendSections([section])
                        let items = oldSnapshot?.itemIdentifiers(inSection: section) ?? []
                        newSnapshot.appendItems(items, toSection: section)
                    }
                })

                return newSnapshot
            }
            .eraseToAnyPublisher()
    }

    var taskNeedingCare: Int {
        let request: NSFetchRequest<SproutCareTaskMO> = SproutCareTaskMO.dueTasksFetchRequest(dueOn: Date())
        return (try? persistentContainer.viewContext.count(for: request)) ?? 0
    }

    // MARK: - Task Methods
    func task(witID id: NSManagedObjectID) -> SproutCareTaskMO? {
        tasksProvider.task(withID: id)
    }

    func plant(withID id: NSManagedObjectID) -> SproutPlantMO? {
        tasksProvider.plant(withID: id)
    }


    func markTaskAsComplete(id: NSManagedObjectID) {
        guard let task = tasksProvider.task(withID: id) else { return }
        task.markAsComplete()
    }

    func showAllCompletedTasks() {
        doesShowAllCompletedTasks = true
        tasksProvider.doesShowCompletedTasks = true
    }

    func hidePreviousCompletedTasks() {
        if doesShowAllCompletedTasks == true {
            doesShowAllCompletedTasks = false
            taskMarkerDate = Date()
        }

        if tasksProvider.doesShowCompletedTasks == true {
            tasksProvider.doesShowCompletedTasks = false
        }
    }
}
