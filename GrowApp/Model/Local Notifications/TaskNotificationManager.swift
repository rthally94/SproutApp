//
//  TaskNotificationManager.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/21/21.
//

import Combine
import CoreData

final class TaskNotificationManager {
    lazy var persistentContainer = AppDelegate.persistentContainer
    private lazy var remindersProvider = ReminderNotificationProvider(managedObjectContext: persistentContainer.viewContext)
    private lazy var notificationsManager = LocalNotificationManager()
    
    private var cancellables = Set<AnyCancellable>()


    var areNotificationsEnabled: Bool {
        !cancellables.isEmpty
    }

    var scheduledTimeComponents = DateComponents()

    func registerForNotifications() {
        notificationsManager.requestAuthorization { [weak self] granted in
            if granted {
                self?.startNotifications()
            }
        }
    }
    
    func startNotifications() {
        remindersProvider.$data
            .map { data in
                data?.reduce(into: [LocalNotification](), { notifications, taskData in
                    let dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: taskData.key)
                    let timeComponents: DateComponents
                    if let userTimeString = UserDefaults.standard.string(forKey: .dailyDigestDate),
                       let userTime = Date(rawValue: userTimeString) {
                        timeComponents = Calendar.current.dateComponents([.hour, .minute], from: userTime)
                    } else {
                        timeComponents = DateComponents(hour: 7, minute: 30)
                    }
                    let notificationTimeComponents = DateComponents(year: dueDateComponents.year, month: dueDateComponents.month, day: dueDateComponents.day, hour: timeComponents.hour, minute: timeComponents.minute)

                    let tasks = taskData.value
                    let taskPlantNames = tasks.compactMap { $0.plant?.nickname ?? $0.plant?.commonName }
                    let taskCount = tasks.reduce(0) { currentCount, task in
                        task.historyLog == nil ? currentCount + 1 : currentCount
                    }
                    
                    let notificationTitle = "Plant Care Due Today"
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
                    notifications.append(notification)
                }) ?? []
            }
            .sink { [weak self] data in
                if let scheduledDateComponents = data.first?.datetime {
                    self?.scheduledTimeComponents = DateComponents(hour: scheduledDateComponents.hour, minute: scheduledDateComponents.minute)
                }

                self?.notificationsManager.removeAllScheduledNotifications()
                self?.notificationsManager.scheduleNotifications(data)
            }
            .store(in: &cancellables)
    }
    
    func stopNotifications() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
