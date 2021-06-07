//
//  AppDelegate.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/15/21.
//

import CoreData
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    static var hasLaunched: Bool {
        get { UserDefaults.standard.bool(forKey: UserDefaults.Keys.hasLaunched) }
        set { UserDefaults.standard.setValue(newValue, forKey: UserDefaults.Keys.hasLaunched) }
    }

    static var storageProvider: StorageProvider {
        (UIApplication.shared.delegate as! AppDelegate).storageProvider
    }

    static var persistentContainer: NSPersistentContainer {
        storageProvider.persistentContainer
    }

    static var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    var storageProvider = StorageProvider()
    var taskNotificationManager = TaskNotificationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        NotificationCenter.default.addObserver(self, selector: #selector(updateNotificationsState), name: UserDefaults.didChangeNotification, object: nil)

        updateNotificationsState()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    @objc private func updateNotificationsState() {
        let notificationsAreEnabled = UserDefaults.standard.bool(forKey: .dailyDigestIsEnabled)

        let notificationTimeComponents: DateComponents = {
            guard let dateTimeString = UserDefaults.standard.string(forKey: .dailyDigestDate), let dateTime = Date(rawValue: dateTimeString) else { return DateComponents() }
            return Calendar.current.dateComponents([.hour, .minute], from: dateTime)
        }()

        if notificationsAreEnabled != taskNotificationManager.areNotificationsEnabled ||  notificationTimeComponents != taskNotificationManager.scheduledTimeComponents {
            taskNotificationManager.registerForNotifications()
        } else {
            print("User has disabled notifications in settings")
            taskNotificationManager.stopNotifications()
        }
    }
}

