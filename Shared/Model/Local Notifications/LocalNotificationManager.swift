//
//  LocalNotificationManager.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/20/21.
//

import UIKit
import UserNotifications

struct LocalNotification: Hashable {
    let id: String
    let title: String?
    let body: String?
    let badgeValue: Int
    let datetime: DateComponents
    
    func makeRequest() -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        if let title = title {
            content.title = title
        }
        
        if let body = body {
            content.body = body
        }
        
        content.sound = UNNotificationSound.default
        content.userInfo["badgeValue"] = badgeValue

        let trigger = UNCalendarNotificationTrigger(dateMatching: datetime, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        return request
    }
}

extension LocalNotification {
    init?(request: UNNotificationRequest) {
        self.id = request.identifier
        self.title = request.content.title
        self.body = request.content.body

        self.badgeValue = request.content.userInfo["badgeValue"] as? Int ?? 0

        guard let trigger = request.trigger as? UNCalendarNotificationTrigger else { return nil }
        self.datetime = trigger.dateComponents
    }
}

class LocalNotificationManager: NSObject, ObservableObject {
    static var shared = LocalNotificationManager()
    @Published var settings: UNNotificationSettings?


    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) {[weak self] granted, _ in
                guard let self = self else { return }
                self.fetchNotificationSettings()
                DispatchQueue.main.async {
                    completion(granted)
                }
        }
    }
    
    func fetchNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings {[weak self] settings in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.settings = settings
            }
        }
    }

    func scheduleNotifications(_ notifications: [LocalNotification]) {
        notifications.forEach { notification in
            let request = notification.makeRequest()
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print(error)
                }
            }

            if let calendarTrigger = request.trigger as? UNCalendarNotificationTrigger,
               let nextDate = calendarTrigger.nextTriggerDate(),
               Calendar.current.isDateInToday(nextDate) {
                UIApplication.shared.applicationIconBadgeNumber = request.content.userInfo["badgeValue"] as? Int ?? 0
            }
        }
    }
    
    func removeScheduledNotification(id: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { pendingNotifications in
            guard let matchingNotification = pendingNotifications.first(where: { $0.identifier == id }) else { return }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])

            if let trigger = matchingNotification.trigger as? UNCalendarNotificationTrigger,
               let nextDate = trigger.nextTriggerDate(),
               Calendar.current.isDateInToday(nextDate) {
                UIApplication.shared.applicationIconBadgeNumber-=1
            }
        }
    }
    
    func removeAllScheduledNotifications() {
        UNUserNotificationCenter.current()
            .removeAllPendingNotificationRequests()

        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func getNotifications(completion: @escaping ([LocalNotification]) -> Void ) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let localNotifications = requests.compactMap(LocalNotification.init)
            DispatchQueue.main.async {
                completion(localNotifications)
            }
        }
    }
    
    func listScheduledNotifications() {
        getNotifications { notifications in
            notifications.forEach { notification in
                print(notification)
            }
        }
    }
    
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
      }
    }
}

extension LocalNotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification is about to be presented.")
        let options: UNNotificationPresentationOptions = [.banner, .sound, .badge]
        UIApplication.shared.applicationIconBadgeNumber = notification.request.content.userInfo["badgeValue"] as? Int ?? 0
        
        completionHandler(options)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.actionIdentifier
        
        switch identifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Default Action")
        default:
            print("Unknown Action")
        }
        
        completionHandler()
    }
    
    
}
