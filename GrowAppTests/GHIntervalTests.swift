//
//  GHIntervalTests.swift
//  GrowAppTests
//
//  Created by Ryan Thally on 5/4/21.
//

import XCTest
@testable import GrowApp

class GHIntervalTests: XCTestCase {
    var storageProvider: StorageProvider!

    override func setUpWithError() throws {
        storageProvider = StorageProvider(storeType: .inMemory)
    }

    func testInitialState() {
        let interval = GHTaskInterval(context: storageProvider.persistentContainer.viewContext)
        XCTAssertEqual(interval.repeatsFrequency, GHTaskIntervalType.never.rawValue)
        XCTAssertNil(interval.repeatsValues)
        XCTAssertNil(interval.startDate)
    }

    // MARK: - Test Next Date
    func testNextDate_FrequencyIsNever_NextIsNil() {
        let interval = GHTaskInterval(context: storageProvider.persistentContainer.viewContext)
        interval.repeatsFrequency = GHTaskIntervalType.never.rawValue
        let testDate = Date()
        XCTAssertNil(interval.nextDate(after: testDate))
    }

    func testNextDate_FrequencyIsDaily_NextIsTheDayAfterInputDate() {
        let interval = GHTaskInterval(context: storageProvider.persistentContainer.viewContext)
        interval.repeatsFrequency = GHTaskIntervalType.daily.rawValue
        interval.repeatsValues = [1]
        let testDate = Date()
        let nextDate = interval.nextDate(after: testDate)
        let resultDate = Calendar.current.startOfDay(for: testDate.advanced(by: 1*24*60*60))
        XCTAssertEqual(nextDate, resultDate)
    }

    func testNextDate_FrequencyIsDaily_NextIs7DaysAfterInputDate() {
        let interval = GHTaskInterval(context: storageProvider.persistentContainer.viewContext)
        interval.repeatsFrequency = GHTaskIntervalType.daily.rawValue
        interval.repeatsValues = [7]
        let testDate = Date()
        let nextDate = interval.nextDate(after: testDate)
        let resultDate = Calendar.current.startOfDay(for: testDate.advanced(by: 7*24*60*60))
        XCTAssertEqual(nextDate, resultDate)
    }

    func testNextDate_FrequencyIsWeekly_NextisAfterInputDate() {
        let interval = GHTaskInterval(context: storageProvider.persistentContainer.viewContext)
        interval.repeatsFrequency = GHTaskIntervalType.weekly.rawValue
        interval.repeatsValues = [2,4,6]
        let testDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 1))!
        let nextDate = interval.nextDate(after: testDate)
        let resultDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 3))!
        XCTAssertEqual(nextDate, resultDate)
    }

    func testNextDate_FrequencyIsWeekly_InputDateWeekdayIsAfterValues_NextisFirstValueNextWeek() {
        let interval = GHTaskInterval(context: storageProvider.persistentContainer.viewContext)
        interval.repeatsFrequency = GHTaskIntervalType.weekly.rawValue
        interval.repeatsValues = [2,4,6]
        let testDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 5))!
        let nextDate = interval.nextDate(after: testDate)
        let resultDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 8))!
        XCTAssertEqual(nextDate, resultDate)
    }

    func testNextDate_FrequencyIsMonthly_InputDateDayIsOnValue_NextIsAfterValue() {
        let interval = GHTaskInterval(context: storageProvider.persistentContainer.viewContext)
        interval.repeatsFrequency = GHTaskIntervalType.monthly.rawValue
        interval.repeatsValues = [1,15]
        let testDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 1))!
        let nextDate = interval.nextDate(after: testDate)
        let resultDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 15))!
        XCTAssertEqual(nextDate, resultDate)
    }

    func testNextDate_FrequencyIsMonthly_InputDateDayIsAfterLastValue_NextIsFirstValueNextMonth() {
        let interval = GHTaskInterval(context: storageProvider.persistentContainer.viewContext)
        interval.repeatsFrequency = GHTaskIntervalType.monthly.rawValue
        interval.repeatsValues = [1,15]
        let testDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 15))!
        let nextDate = interval.nextDate(after: testDate)
        let resultDate = Calendar.current.date(from: DateComponents(year: 2021, month: 4, day: 1))!
        XCTAssertEqual(nextDate, resultDate)
    }
}
