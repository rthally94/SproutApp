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
    
    init(id: String, title: String?, body: String?, badgeValue: Int, datetime: DateComponents) {
        self.id = id
        self.title = title
        self.body = body
        self.badgeValue = badgeValue
        self.datetime = datetime
    }
    
    init?(request: UNNotificationRequest) {
        self.id = request.identifier
        self.title = request.content.title
        self.body = request.content.body
        
        self.badgeValue = request.content.userInfo["badgeValue"] as? Int ?? 0
        
        guard let trigger = request.trigger as? UNCalendarNotificationTrigger else { return nil }
        self.datetime = trigger.dateComponents
    }
    
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
        
        print("Local:", datetime, " | Trigger:", trigger.dateComponents)
        print(trigger.nextTriggerDate())
        return request
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
            .requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                self.fetchNotificationSettings()
                DispatchQueue.main.async {
                    completion(granted)
                }
        }
    }
    
    func fetchNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.settings = settings
            }
        }
    }
    
    func removeScheduledNotification(id: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func removeAllScheduledNotifications() {
        UNUserNotificationCenter.current()
            .removeAllPendingNotificationRequests()
    }
    
    func scheduleNotifications(_ notifications: [LocalNotification]) {
        notifications.forEach { notification in
            let request = notification.makeRequest()
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print(error)
                } else {
                    print("Scheduled")
                }
            }
            
            if let calendarTrigger = request.trigger as? UNCalendarNotificationTrigger,
               let nextDate = calendarTrigger.nextTriggerDate(),
               Calendar.current.isDateInToday(nextDate) {
                UIApplication.shared.applicationIconBadgeNumber = request.content.userInfo["badgeValue"] as? Int ?? 0
            }
        }
        
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
