//
//  SproutReminder.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/17/21.
//

import Combine
import CoreData

enum SproutReminderError: Error {
    case reminderLockedError
}

enum SproutReminderStatus: String {
    case incomplete, marking, complete
}

public class SproutReminder: NSManagedObject {
    var status: SproutReminderStatus {
        set { statusType = newValue.rawValue }
        get {
            guard let statusType = statusType, let status = SproutReminderStatus(rawValue: statusType) else { return .incomplete }
            return status
        }
    }

    var isLocked: Bool {
        switch status {
        case .incomplete:
            return false
        default:
            return true
        }
    }

    private var cancellabes: Set<AnyCancellable> = []

    public override func awakeFromInsert() {
        super.awakeFromInsert()

        subscribeToSchedule()
    }

    public override func awakeFromFetch() {
        super.awakeFromFetch()

        subscribeToSchedule()
    }

    private func subscribeToSchedule() {
        schedule?.objectWillChange
            .sink(receiveValue: { [weak self] _ in
                self?.updateScheduledDateIfNeeded()
            })
            .store(in: &cancellabes)
    }

    @objc private func scheduleDidSave(_ notification: Notification) {
        var shoudUpdateScheduledDate = false

        if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
            print("--- Inserted ---")
            print(insertedObjects)

            if let schedule = schedule, insertedObjects.contains(where: { $0.objectID == schedule.objectID }) {
                shoudUpdateScheduledDate = true
            }

            if let recurrenceRule = schedule?.recurrenceRule, insertedObjects.contains(where: { $0.objectID == recurrenceRule.objectID }) {
                shoudUpdateScheduledDate = true
            }
        }

        if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
            print("--- Updated ---")
            print(updatedObjects)

            if let schedule = schedule, updatedObjects.contains(where: { $0.objectID == schedule.objectID }) {
                shoudUpdateScheduledDate = true
            }

            if let recurrenceRule = schedule?.recurrenceRule, updatedObjects.contains(where: { $0.objectID == recurrenceRule.objectID }) {
                shoudUpdateScheduledDate = true
            }
        }

        if shoudUpdateScheduledDate {
            updateScheduledDateIfNeeded()
        }
    }
}

// MARK: - Actions
// These methods are used to mutate state in a predicatble way.
extension SproutReminder {
    func markAs(_ newState: SproutReminderStatus, date: Date = Date()) {
        switch newState {
        case .complete:
            status = newState
            statusDate = date
        case .marking:
            status = newState
            statusDate = date
        case .incomplete:
            status = newState
            statusDate = nil
        }
    }

    func updateScheduledDateIfNeeded() {
        let referenceDate = Calendar.current.startOfDay(for: Date()).addingTimeInterval(-1*24*60*60)
        let newDate = schedule?.recurrenceRule?.nextDate(after: referenceDate)

        if let currentDate = scheduledDate,
           let newDate = newDate,
           let difference = Calendar.current.dateComponents([.day], from: currentDate, to: newDate).day,
           difference != 0 {
            scheduledDate = newDate
        } else {
            scheduledDate = newDate
        }
    }
}

// MARK: - Initializers
extension SproutReminder {
    static func createDefaultReminder(inContext context: NSManagedObjectContext) -> SproutReminder {
        let newReminder = SproutReminder(context: context)
        newReminder.creationDate = Date()
        newReminder.id = UUID()
        newReminder.status = .incomplete
        newReminder.statusDate = nil
        newReminder.scheduledDate = nil

        return newReminder
    }
}

// MARK: - Fetch Requests
extension SproutReminder {
    static func fetchOrCreateIncompleteReminder(for careInfoItem: CareInfo, inContext context: NSManagedObjectContext) -> SproutReminder {
        // Try and find an existing incomplte task for the info item
        if let task = try? context.fetch(Self.incompleteRemindersFetchRequest(for: careInfoItem, startingOn: nil, endingBefore: nil)).first {
            task.schedule = careInfoItem.currentSchedule
            return task
        }

        // Create a new reminder item
        let newReminder = Self.createDefaultReminder(inContext: context)
        newReminder.careInfo = careInfoItem
        newReminder.schedule = careInfoItem.currentSchedule

        return newReminder
    }

    static func fetchRequest(withStatus status: SproutReminderStatus? = nil, for careInfoItem: CareInfo? = nil, startingOn startDate: Date? = nil, endingBefore endDate: Date? = nil) -> NSFetchRequest<SproutReminder> {
        let statusPredicate = status == nil ? NSPredicate.init(value: true) : NSPredicate(format: "%K == %@", #keyPath(SproutReminder.statusType), status!.rawValue)
        let infoItemPredicate = careInfoItem == nil ? NSPredicate(value: true) : NSPredicate(format: "%K == %@", #keyPath(SproutReminder.careInfo), careInfoItem!)
        let startDatePredicate = startDate == nil ? NSPredicate(value: true) : NSPredicate(format: "%K >= %@", #keyPath(SproutReminder.scheduledDate), startDate! as CVarArg)
        let endDatePredicate = endDate == nil ? NSPredicate(value: true) : NSPredicate(format: "%K < %@", #keyPath(SproutReminder.scheduledDate), endDate! as CVarArg)

        let request: NSFetchRequest<SproutReminder> = SproutReminder.fetchRequest()

        let sortByDueDate = NSSortDescriptor(keyPath: \SproutReminder.scheduledDate, ascending: true)
        let sortByPlantName = NSSortDescriptor(keyPath: \SproutReminder.careInfo?.plant?.name, ascending: true)
        
        request.sortDescriptors = [sortByDueDate, sortByPlantName]

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [statusPredicate, infoItemPredicate, startDatePredicate, endDatePredicate])

        return request
    }

    static func incompleteRemindersFetchRequest(for careInfoItem: CareInfo? = nil, startingOn startDate: Date?, endingBefore endDate: Date?) -> NSFetchRequest<SproutReminder> {
        let request = SproutReminder.fetchRequest(withStatus: .incomplete, for: careInfoItem, startingOn: startDate, endingBefore: endDate)
        return request
    }

    static func completedRemindersFetchRequest(for careInfoItem: CareInfo? = nil, startingOn startDate: Date?, endingBefore endDate: Date?) -> NSFetchRequest<SproutReminder> {
        let request = SproutReminder.fetchRequest(withStatus: .complete, for: careInfoItem, startingOn: startDate, endingBefore: endDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SproutReminder.statusDate, ascending: false)]
        return request
    }

    static func allRemindersFetchRequest(for careInfoItem: CareInfo? = nil, startingOn startDate: Date?, endingBefore endDate: Date?) -> NSFetchRequest<SproutReminder> {
        let request = SproutReminder.fetchRequest(for: careInfoItem, startingOn: startDate, endingBefore: endDate)
        return request
    }
}
