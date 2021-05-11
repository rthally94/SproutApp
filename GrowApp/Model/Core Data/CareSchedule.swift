//
//  CareSchedule.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/11/21.
//

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
}
