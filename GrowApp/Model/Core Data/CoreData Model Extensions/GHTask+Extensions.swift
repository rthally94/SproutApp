//
//  GHTask+Extensions.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/1/21.
//

import Foundation
import CoreData

//extension GHTask {
//    class func isDateInIntervalPredicate(_ date: Date) -> NSPredicate {
//        let startOfDate = Calendar.current.startOfDay(for: date)
//        // isStartDate after desiredDate
//        let isStartDateAfterDesiredDatePredicate = NSPredicate(format: "%K >= %@", #keyPath(GHTask.interval.startDate), startOfDate as NSDate)
//
//        // none
//        let isTypeNonePredicate = NSPredicate(format: "%K = %d", #keyPath(GHTask.interval.type), Int16(GHTaskIntervalType.none.rawValue))
//        let nonePredicate = isTypeNonePredicate
//
//        // daily
//        let isTypeDailyPredicate = NSPredicate(format: "%K == %d", #keyPath(GHTask.interval.type), Int16(GHTaskIntervalType.daily.rawValue))
//        let dailyPredicate = isTypeDailyPredicate
//
//        // weekly
//        let weekday = Calendar.current.component(.weekday, from: startOfDate)
//        let isTypeWeeklyPredicate = NSPredicate(format: "%K = %d", #keyPath(GHTask.interval.type), Int16(GHTaskIntervalType.weekly.rawValue))
//        let isWeekdayInIntervalPredicate = NSPredicate(format: "%d IN %K", weekday, #keyPath(GHTask.interval.values))
//        let weeklyPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [isTypeWeeklyPredicate, isWeekdayInIntervalPredicate])
//
//        //monthly
//        let day = Calendar.current.component(.day, from: startOfDate)
//        let isTypeMonthlyPredicate = NSPredicate(format: "%K == %d", #keyPath(GHTask.interval.type), GHTaskIntervalType.monthly.rawValue)
//        let isDayInIntervalPredicate = NSPredicate(format: "%d IN %K", day, #keyPath(GHTask.interval.values))
//        let monthlyPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [isTypeMonthlyPredicate, isDayInIntervalPredicate])
//
//        let intervalPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [nonePredicate, dailyPredicate, weeklyPredicate, monthlyPredicate])
//        let resultPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [isStartDateAfterDesiredDatePredicate, intervalPredicate])
//        return resultPredicate
//    }
//}

//extension GHTask {
//    var lastCareDate: Date? {
//        return nil
//    }
//
//    func nextCareDate(after date: Date) -> Date? {
//        guard let startDate = interval?.startDate, date >= startDate else { return interval?.startDate }
//
//        let intervalType = GHTaskIntervalType(rawValue: Int(interval?.type ?? Int16(0)))
//        switch intervalType {
//            case nil, .none?:
//                return nil
//            case .daily:
//                // Calculate elapsed days since start to desired day
//                let daysSinceStartingDate = Calendar.current.dateComponents([.day], from: startDate, to: date)
//
//                // Divide by interval to determine the number of interval periods that have elapsed.
//                let days = (interval?.components as? Set<GHDateComponent>)?.first?.dateCompoent.day ?? 1
//                let intervalsSinceStartingDate = daysSinceStartingDate.day ?? 0 / days
//
//                // Get the Date N + 1 interval periods from the starting date
//                let nextIntervalDate = Calendar.current.date(byAdding: .day, value: (intervalsSinceStartingDate + 1) * days, to: startDate)
//                return nextIntervalDate
//
//            case .weekly:
//                // Get weekday from desired date
//                let weekdayToCheck = Calendar.current.component(.weekday, from: date)
//
//                // Get the weekday after the desired date
//                let sortedWeekdays = (interval?.components as? Set<GHDateComponent>)?.sorted(by: { $0.dateComponent < $1.dateCompoent }) ?? []
//                let nextWeekday = sortedWeekdays.first(where: { $0 > weekdayToCheck }) ?? sortedWeekdays.first
//
//                // Calcualte the date of the next weekday
//                let components = DateComponents(weekday: nextWeekday)
//                return Calendar.current.nextDate(after: date, matching: components, matchingPolicy: .nextTime)
//
//            case .monthly:
//                // Get the day of the desired date
//                let desiredDay = Calendar.current.component(.day, from: date)
//
//                // Get the day after the desired date
//                let sortedDays = (interval?.components as? Set<GHDateComponent>)?.sorted(by: { $0.dateComponent < $1.dateCompoent }) ?? []
//                let nextDay = sortedDays.first(where: {$0 > desiredDay }) ?? sortedDays.first
//
//                // Calculate the date of the next day
//                let components = DateComponents(day: nextDay)
//                return Calendar.current.nextDate(after: date, matching: components, matchingPolicy: .nextTime)
//        }
//    }
//
//    func previousCareDate(before date: Date) -> Date? {
//        guard let startDate = interval?.startDate, date >= startDate else { return interval?.startDate }
//
//        let intervalType = GHTaskIntervalType(rawValue: Int(interval?.type ?? 0))
//        switch intervalType {
//            case nil, .none?:
//                return nil
//            case .daily:
//                // Calculate elapsed days since start to desired day
//                let daysSinceStartingDate = Calendar.current.dateComponents([.day], from: startDate, to: date)
//
//                // Divide by interval to determine the number of interval periods that have elapsed.
//                let days = interval?.values?.first ?? 1
//                let intervalsSinceStartingDate = daysSinceStartingDate.day ?? 0 / days
//
//                if intervalsSinceStartingDate > 0 {
//                    // Get the Date N + 1 interval periods from the starting date
//                    let nextIntervalDate = Calendar.current.date(byAdding: .day, value: (intervalsSinceStartingDate - 1) * days, to: startDate)
//                    return nextIntervalDate
//                } else {
//                    return startDate
//                }
//
//            case .weekly:
//                // Get weekday from desired date
//                let weekdayToCheck = Calendar.current.component(.weekday, from: date)
//
//                // Get the weekday after the desired date
//                let sortedWeekdays = interval?.values?.sorted().reversed() ?? []
//                let nextWeekday = sortedWeekdays.first(where: { $0 < weekdayToCheck }) ?? sortedWeekdays.first
//
//                // Calcualte the date of the next weekday
//                let components = DateComponents(weekday: nextWeekday)
//                if let previousDate = Calendar.current.nextDate(after: date, matching: components, matchingPolicy: .nextTime, direction: .backward), previousDate >= startDate {
//                    return previousDate
//                } else {
//                    return startDate
//                }
//
//            case .monthly:
//                // Get the day of the desired date
//                let desiredDay = Calendar.current.component(.day, from: date)
//
//                // Get the day after the desired date
//                let sortedDays = interval?.values?.sorted().reversed() ?? []
//                let nextDay = sortedDays.first(where: {$0 > desiredDay }) ?? sortedDays.first
//
//                // Calculate the date of the next day
//                let components = DateComponents(day: nextDay)
//                if let previousDate = Calendar.current.nextDate(after: date, matching: components, matchingPolicy: .nextTime, direction: .backward), previousDate >= startDate {
//                    return previousDate
//                } else {
//                    return startDate
//                }
//        }
//    }
//
//    func isDateInInterval(_ date: Date) -> Bool {
//        // Test date must be after the starting date
//        guard let startDate = interval?.startDate, date >= startDate else { return false }
//
//        let intervalType = GHTaskIntervalType(rawValue: Int(interval?.type ?? 0))
//        switch intervalType {
//            case nil, .none?: return true
//            case .daily:
//                // Calculate elapsed days since start to desired day
//                guard let daysSinceStartingDate = Calendar.current.dateComponents([.day], from: startDate, to: date).day else { return false }
//
//                // Divide by interval to determine the number of interval periods that have elapsed.
//                let days = interval?.values?.first ?? 1
//                let remainder = daysSinceStartingDate % days
//                return remainder == 0
//
//            case .weekly:
//                let inputWeekday = Calendar.current.component(.weekday, from: date)
//                let weekdays = interval?.values ?? []
//                return weekdays.contains(inputWeekday)
//
//            case .monthly:
//                let inputDay = Calendar.current.component(.day, from: date)
//                let days = interval?.values ?? []
//                return days.contains(inputDay)
//        }
//    }
//
//    func isLate() -> Bool {
//        if let lastCareDate = lastCareDate, let nextCareDate = nextCareDate(after: lastCareDate), nextCareDate < Calendar.current.startOfDay(for: Date()) {
//            return true
//        } else {
//            return false
//        }
//    }
//}
