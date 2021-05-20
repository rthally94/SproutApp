//
//  LocalNotificationManager.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/20/21.
//

import UserNotifications

struct LocalNotification: Hashable {
    var id: UUID
    var title: String
    var body: String
    var datetime: DateComponents

    static func createCareNotification(numberOfPlants: Int, onDate desiredDate: Date) -> LocalNotification {
        let body = "\(numberOfPlants) of your plants needs care today."
        let components = Calendar.current.dateComponents([.year, .month, .day], from: desiredDate)

        return LocalNotification(id: UUID(), title: "You've got care", body: body, datetime: components)
    }
}

class LocalNotificationManager {
    var notifications = Set<LocalNotification>()

    func listScheduledNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            for notification in notifications {
                print(notification)
            }
        }
    }

    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted == true && error == nil {
                self.schedule()
            }
        }
    }

    private func schedule() {
        notifications.forEach {
            let content = UNMutableNotificationContent()
            content.title = $0.title
            content.body = $0.body
            content.sound = UNNotificationSound.default

            let trigger = UNCalendarNotificationTrigger(dateMatching: $0.datetime, repeats: false)
            let request = UNNotificationRequest(identifier: $0.id.uuidString, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print(error)
                }
            }
        }
    }
}
