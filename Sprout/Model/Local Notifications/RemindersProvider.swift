//
//  RemindersProvider.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/21/21.
//

import CoreData
import Combine
import Foundation

class ReminderNotificationProvider: NSObject {
    let moc: NSManagedObjectContext
    
    @Published var data: [Date: [SproutCareTaskMO]]?
    private let request = SproutCareTaskMO.remindersFetchRequest()

    init(managedObjectContext: NSManagedObjectContext) {
        self.moc = managedObjectContext
        super.init()

        updateData()

        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave), name: .NSManagedObjectContextDidSave, object: moc)
    }

    @objc private func contextDidSave() {
        updateData()
    }
    
    func updateData() {
        moc.perform { [weak self] in
            guard let self = self else { return }
            guard let reminders = try? self.moc.fetch(self.request) else { return }

            let midnightToday = Calendar.current.startOfDay(for: Date())
            self.data = reminders.reduce(into: [Date: [SproutCareTaskMO]](), { result, task in
                if let scheduledDate = task.dueDate {
                    // Any tasks that scheduled care before today, will be grouped in today
                    let date = Calendar.current.startOfDay(for: scheduledDate < midnightToday ? midnightToday : scheduledDate)
                    result[date, default: []].append(task)
                }
            })
        }
    }
}
