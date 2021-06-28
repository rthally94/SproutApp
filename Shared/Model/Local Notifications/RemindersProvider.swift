//
//  RemindersProvider.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/21/21.
//

import CoreData
import Combine
import Foundation
import SproutKit

class ReminderNotificationProvider: NSObject {
    let moc: NSManagedObjectContext
    
    @Published var data: [LocalNotification]?
    private let request = SproutCareTaskMO.remindersFetchRequest()

    init(managedObjectContext: NSManagedObjectContext) {
        self.moc = managedObjectContext
        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave), name: .NSManagedObjectContextDidSave, object: moc)
    }

    @objc private func contextDidSave() {
        updateData()
    }
    
    func updateData() {
        moc.perform {
            do {
                let data = try self.moc.fetch(self.request)
                let processedData = data
                    // Group tasks by due date
                    .reduce(into: [Date: [SproutCareTaskMO]]()) { result, task in
                        var notificationDate: Date?
                        let midnightToday = Calendar.current.startOfDay(for: Date())
                        if task.dueDate < midnightToday {
                            notificationDate = midnightToday
                        } else if let dueDate = task.dueDate {
                            notificationDate = Calendar.current.startOfDay(for: dueDate)
                        }

                        if let date = notificationDate {
                            result[date, default: []].append(task)
                        }
                    }
                    // Convert to an array of notifications
                    .map { date, tasks -> LocalNotification in
                        let dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
                        let timeComponents: DateComponents
                        if let userTime = UserDefaults.standard.dailyDigestDate {
                            timeComponents = Calendar.current.dateComponents([.hour, .minute], from: userTime)
                        } else {
                            timeComponents = DateComponents(hour: 7, minute: 30)
                        }
                        let notificationTimeComponents = DateComponents(year: dueDateComponents.year, month: dueDateComponents.month, day: dueDateComponents.day, hour: timeComponents.hour, minute: timeComponents.minute)

                        let taskPlantNames = tasks.compactMap { $0.plant?.nickname ?? $0.plant?.commonName }
                        let taskCount = tasks.count

                        let notificationTitle = "Daily Care Digest"
                        var notificationBody: String?

                        switch taskCount {
                        case 1:
                            if let reminderList = ListFormatter().string(from: taskPlantNames) {
                                notificationBody = reminderList + " needs care today."
                            }
                        case 2, 3:
                            if let reminderList = ListFormatter().string(from: taskPlantNames) {
                                notificationBody = reminderList + " need care today."
                            }
                        case 4...:
                            let remainingItemsCount = taskCount - 3
                            var items = Array(taskPlantNames.prefix(3))
                            items.append("\(remainingItemsCount) other plants need care today.")

                            notificationBody = ListFormatter().string(from: items)
                        default:
                            break
                        }

                        let notification = LocalNotification(id: UUID().uuidString, title: notificationTitle, body: notificationBody, badgeValue: taskCount, datetime: notificationTimeComponents)
                        return notification
                    }


                DispatchQueue.main.async {
                    self.data = processedData
                }

                print("--- Start Display Data ---")
                print(processedData)
                print("--- END Display Data ---")
            } catch {
                print("Unable to fetch reminders: \(error)")
            }
        }
    }
}
