//
//  CareSchedule.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/11/21.
//

import Combine
import CoreData

public class CareSchedule: NSManagedObject {
    private static func defaultSchedule(context: NSManagedObjectContext) -> CareSchedule {
        let schedule = CareSchedule(context: context)
        schedule.id = UUID()
        schedule.creationDate = Date()
        schedule.startingDate = Date()
        return schedule
    }

    static func dailySchedule(interval: Int, context: NSManagedObjectContext) -> CareSchedule {
        let recurrenceRule = CareRecurrenceRule.daily(interval: interval, context: context)

        let schedule = defaultSchedule(context: context)
        schedule.recurrenceRule = recurrenceRule

        return schedule
    }

    static func weeklySchedule(daysOfTheWeek: Set<Int>, context: NSManagedObjectContext) -> CareSchedule {
        let recurrenceRule = CareRecurrenceRule.weekly(daysOfTheWeek: daysOfTheWeek, context: context)

        let schedule = defaultSchedule(context: context)
        schedule.recurrenceRule = recurrenceRule
        return schedule
    }

    static func monthlySchedule(daysOfTheMonth: Set<Int>, context: NSManagedObjectContext) -> CareSchedule {
        let recurrenceRule = CareRecurrenceRule.monthly(daysOfTheMonth: daysOfTheMonth, context: context)

        let schedule = defaultSchedule(context: context)
        schedule.recurrenceRule = recurrenceRule
        return schedule
    }

    private var cancellables: Set<AnyCancellable> = []

    public override func awakeFromInsert() {
        super.awakeFromInsert()

        subscribeToRecurrenceRule()
    }

    public override func awakeFromFetch() {
        super.awakeFromFetch()

        subscribeToRecurrenceRule()
    }

    private func subscribeToRecurrenceRule() {
        recurrenceRule?.objectWillChange
            .sink(receiveValue: { [weak self] _ in
                self?.objectWillChange.send()
            })
            .store(in: &cancellables)
    }
}

extension CareSchedule {
    func sortedRemidners() -> [SproutReminder] {
        guard careInfo != nil else { return [] }
        let request = SproutReminder.allRemindersFetchRequest(for: careInfo, startingOn: nil, endingBefore: nil)

        return (try? self.managedObjectContext?.fetch(request)) ?? []
    }

    func pastReminders() -> [SproutReminder] {
        guard careInfo != nil else { return [] }
        let request = SproutReminder.completedRemindersFetchRequest(for: self.careInfo, startingOn: nil, endingBefore: nil)
        return (try? managedObjectContext?.fetch(request)) ?? []
    }
}
