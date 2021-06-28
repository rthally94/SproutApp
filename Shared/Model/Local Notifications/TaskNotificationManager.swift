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
    private lazy var remindersProvider = ReminderNotificationProvider(managedObjectContext: persistentContainer.newBackgroundContext())
    private lazy var notificationsManager = LocalNotificationManager()
    
    private var cancellables: Set<AnyCancellable> = []

    var areNotificationsAuthorized: Bool = false
    var scheduledTimeComponents = DateComponents()

    init() {
        subscribeToNotificationPropertyChanges()
        subscribeToReminders()
    }

    func registerForNotifications() {
        notificationsManager.requestAuthorization { [weak self] granted in
            guard let self = self else { return }
            self.areNotificationsAuthorized = granted
        }
    }
    
    func updateNotifications() {
        if !areNotificationsAuthorized {
            registerForNotifications()
        }

        if UserDefaults.standard.dailyDigestIsEnabled {
            remindersProvider.updateData()
        } else {
            print("--- USER DISABLED NOTIFICATIONS ---")
        }
    }

    private func subscribeToNotificationPropertyChanges() {
        UserDefaults.standard
            .publisher(for: \.dailyDigestIsEnabled)
            .combineLatest(UserDefaults.standard.publisher(for: \.dailyDigestDate))
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .compactMap { isEnabled, date -> (Bool, Date)? in
                if date == nil {
                    return nil
                } else {
                    return (isEnabled, date!)
                }
            }
            .sink { [weak self] isEnabled, dateTime in
                guard let self = self else { return }
                self.updateNotifications()
            }
            .store(in: &cancellables)
    }

    private func subscribeToReminders() {
        remindersProvider.$data
            .compactMap { $0 }  // Unwrap Optional
            .removeDuplicates()
            .sink { [weak self] notifications in
                guard let self = self else { return }
                if let scheduledDateComponents = notifications.first?.datetime {
                    self.scheduledTimeComponents = DateComponents(hour: scheduledDateComponents.hour, minute: scheduledDateComponents.minute)
                }

                DispatchQueue.main.async {
                    self.notificationsManager.removeAllScheduledNotifications()
                    self.notificationsManager.scheduleNotifications(notifications)
                    print("--- NOTIFICATIONS SCHEDULED ---")
                }
            }
            .store(in: &cancellables)
    }
}
