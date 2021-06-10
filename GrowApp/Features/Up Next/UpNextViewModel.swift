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
        tasksProvider.$snapshot.eraseToAnyPublisher()
    }

    var taskNeedingCare: Int {
        let request: NSFetchRequest<SproutCareTaskMO> = SproutCareTaskMO.fetchRequest()
        let midnightToday = Calendar.current.startOfDay(for: Date())
        let midnightTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: midnightToday)!

        let isNotTemplatePredicate = NSPredicate(format: "%K == false", #keyPath(SproutCareTaskMO.isTemplate))
        let needsCareTodayPredicate = NSPredicate(format: "%K < %@", #keyPath(SproutCareTaskMO.dueDate), midnightTomorrow as NSDate)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [isNotTemplatePredicate, needsCareTodayPredicate])

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
        guard let task = task(witID: id) else { return }
        do {
            try task.markAs(.complete) {
                self.persistentContainer.saveContextIfNeeded()
            }
        } catch {
            print("Unable to mark task as complete: \(error)")
        }
    }

    func showAllCompletedTasks() {
        doesShowAllCompletedTasks = true
        tasksProvider.doesShowCompletedTasks = true
    }

    func hidePreviousCompletedTasks() {
        doesShowAllCompletedTasks = false
        tasksProvider.doesShowCompletedTasks = false
        taskMarkerDate = Date()
    }
}
