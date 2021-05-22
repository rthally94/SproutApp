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
    private lazy var remindersProvider = IncompleteRemindersProvider(managedObjectContext: persistentContainer.viewContext)
    private lazy var notificationsManager = LocalNotificationManager()
    
    private var cancellables = Set<AnyCancellable>()
    
    func registerForNotifications() {
        notificationsManager.requestAuthorization { [weak self] granted in
            print("Granted: \(granted)")
            if granted {
                self?.startNotifications()
            }
        }
    }
    
    func startNotifications() {
        remindersProvider.$data
            .map { data in
                data?.reduce(into: [LocalNotification](), { notifications, reminderData in
                    let reminderDate = reminderData.key
                    let reminderItems = reminderData.value
                    
                    let reminderPlantNames = reminderItems.compactMap { $0.careInfo?.plant?.name }
                    let reminderCount = reminderItems.count
                    
                    let notificationTitle = "Plant Care Due Today"
                    var notificationBody: String?
                    var notificationComponents = Calendar.current.dateComponents([.year, .month, .day], from: reminderDate)
                    let todayComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: Date().addingTimeInterval(10))
                    notificationComponents.hour = todayComponents.hour
                    notificationComponents.minute = todayComponents.minute
                    notificationComponents.second = todayComponents.second
                    
                    switch reminderCount {
                    case 1:
                        if let reminderList = ListFormatter().string(from: reminderPlantNames) {
                            notificationBody = reminderList + " needs care today."
                        }
                    case 2, 3:
                        if let reminderList = ListFormatter().string(from: reminderPlantNames) {
                            notificationBody = reminderList + " need care today."
                        }
                    case 4...:
                        let remainingItemsCount = reminderCount - 3
                        var items = Array(reminderPlantNames.prefix(3))
                        items.append("\(remainingItemsCount) other plants need care today.")
                        
                        notificationBody = ListFormatter().string(from: items)
                    default:
                        break
                    }
                    
                    let notification = LocalNotification(id: UUID().uuidString, title: notificationTitle, body: notificationBody, badgeValue: reminderCount, datetime: notificationComponents)
                    notifications.append(notification)
                }) ?? []
            }
            .sink { [weak self] data in
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
