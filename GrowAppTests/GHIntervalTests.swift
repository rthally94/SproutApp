//
//  GHIntervalTests.swift
//  GrowAppTests
//
//  Created by Ryan Thally on 5/4/21.
//

import CoreData
import XCTest
@testable import GrowApp

class CareRecurrenceRuleTests: XCTestCase {
    var storageProvider: StorageProvider!
    var viewContext: NSManagedObjectContext {
        return storageProvider.persistentContainer.viewContext
    }

    override func setUpWithError() throws {
        storageProvider = StorageProvider(storeType: .inMemory)
    }

    func testDailyInitialState() {
        let rule = CareRecurrenceRule.daily(interval: 1, context: viewContext)
        XCTAssertNotNil(rule.id)
        XCTAssertNotNil(rule.creationDate)

        XCTAssertEqual(rule.frequency, SproutRecurrenceFrequency.daily)
        XCTAssertEqual(rule.interval, 1)
        XCTAssertNil(rule.daysOfTheWeek)
        XCTAssertNil(rule.daysOfTheMonth)
    }

    func testWeelyIntervalInitialState() {
        let rule = CareRecurrenceRule.weekly(interval: 1, context: viewContext)
        XCTAssertNotNil(rule.id)
        XCTAssertNotNil(rule.creationDate)

        XCTAssertEqual(rule.frequency, SproutRecurrenceFrequency.weekly)
        XCTAssertEqual(rule.interval, 1)
        XCTAssertNil(rule.daysOfTheWeek)
        XCTAssertNil(rule.daysOfTheMonth)
    }

    func testWeelySpecificDaysInitialState() {
        let rule = CareRecurrenceRule.weekly(daysOfTheWeek: [1], context: viewContext)
        XCTAssertNotNil(rule.id)
        XCTAssertNotNil(rule.creationDate)

        XCTAssertEqual(rule.frequency, SproutRecurrenceFrequency.weekly)
        XCTAssertEqual(rule.interval, 1)
        XCTAssertNotNil(rule.daysOfTheWeek)
        XCTAssertNil(rule.daysOfTheMonth)
    }

    func testMonthlyIntervalInitialState() {
        let rule = CareRecurrenceRule.monthly(interval: 1, context: viewContext)
        XCTAssertNotNil(rule.id)
        XCTAssertNotNil(rule.creationDate)

        XCTAssertEqual(rule.frequency, SproutRecurrenceFrequency.monthly)
        XCTAssertEqual(rule.interval, 1)
        XCTAssertNil(rule.daysOfTheWeek)
        XCTAssertNil(rule.daysOfTheMonth)
    }

    func testMonthlySpecificDaysInitialState() {
        let rule = CareRecurrenceRule.monthly(daysOfTheMonth: [1], context: viewContext)
        XCTAssertNotNil(rule.id)
        XCTAssertNotNil(rule.creationDate)

        XCTAssertEqual(rule.frequency, SproutRecurrenceFrequency.monthly)
        XCTAssertEqual(rule.interval, 1)
        XCTAssertNil(rule.daysOfTheWeek)
        XCTAssertNotNil(rule.daysOfTheMonth)
    }

    // MARK: - Test Next Date
    func testNextDate_FrequencyIsNever_NextIsNil() {
        let interval = CareRecurrenceRule(context: storageProvider.persistentContainer.viewContext)
        interval.frequency = SproutRecurrenceFrequency.never
        let testDate = Date()
        XCTAssertNil(interval.nextDate(after: testDate))
    }

    func testNextDate_FrequencyIsDaily_NextIsTheDayAfterInputDate() {
        let interval = CareRecurrenceRule(context: storageProvider.persistentContainer.viewContext)
        interval.frequency = SproutRecurrenceFrequency.daily
        interval.interval = 1
        let testDate = Date()
        let nextDate = interval.nextDate(after: testDate)
        let resultDate = Calendar.current.startOfDay(for: testDate.advanced(by: 1*24*60*60))
        XCTAssertEqual(nextDate, resultDate)
    }

    func testNextDate_FrequencyIsDaily_NextIs7DaysAfterInputDate() {
        let interval = CareRecurrenceRule(context: storageProvider.persistentContainer.viewContext)
        interval.frequency = SproutRecurrenceFrequency.daily
        interval.interval = 7
        let testDate = Date()
        let nextDate = interval.nextDate(after: testDate)
        let resultDate = Calendar.current.startOfDay(for: testDate.advanced(by: 7*24*60*60))
        XCTAssertEqual(nextDate, resultDate)
    }

    func testNextDate_FrequencyIsWeekly_NextisAfterInputDate() {
        let interval = CareRecurrenceRule(context: storageProvider.persistentContainer.viewContext)
        interval.frequency = SproutRecurrenceFrequency.weekly
        interval.daysOfTheWeek = [2,4,6]
        let testDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 1))!
        let nextDate = interval.nextDate(after: testDate)
        let resultDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 3))!
        XCTAssertEqual(nextDate, resultDate)
    }

    func testNextDate_FrequencyIsWeekly_InputDateWeekdayIsAfterValues_NextisFirstValueNextWeek() {
        let interval = CareRecurrenceRule(context: storageProvider.persistentContainer.viewContext)
        interval.frequency = SproutRecurrenceFrequency.weekly
        interval.daysOfTheWeek = [2,4,6]
        let testDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 5))!
        let nextDate = interval.nextDate(after: testDate)
        let resultDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 8))!
        XCTAssertEqual(nextDate, resultDate)
    }

    func testNextDate_FrequencyIsMonthly_InputDateDayIsOnValue_NextIsAfterValue() {
        let interval = CareRecurrenceRule(context: storageProvider.persistentContainer.viewContext)
        interval.frequency = SproutRecurrenceFrequency.monthly
        interval.daysOfTheMonth = [1,15]
        let testDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 1))!
        let nextDate = interval.nextDate(after: testDate)
        let resultDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 15))!
        XCTAssertEqual(nextDate, resultDate)
    }

    func testNextDate_FrequencyIsMonthly_InputDateDayIsAfterLastValue_NextIsFirstValueNextMonth() {
        let interval = CareRecurrenceRule(context: storageProvider.persistentContainer.viewContext)
        interval.frequency = SproutRecurrenceFrequency.monthly
        interval.daysOfTheMonth = [1,15]
        let testDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 15))!
        let nextDate = interval.nextDate(after: testDate)
        let resultDate = Calendar.current.date(from: DateComponents(year: 2021, month: 4, day: 1))!
        XCTAssertEqual(nextDate, resultDate)
    }
}
