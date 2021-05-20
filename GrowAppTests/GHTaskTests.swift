//
//  CareInfoTests.swift
//  GrowAppTests
//
//  Created by Ryan Thally on 5/4/21.
//

import XCTest
@testable import GrowApp

class CareInfoTests: XCTestCase {
    var storageProvider: StorageProvider!
    
    override func setUpWithError() throws {
        storageProvider = StorageProvider(storeType: .inMemory)
    }

    func testWateringTaskInitalState() throws {
        let careInfoItem = try CareInfo.createDefaultInfoItem(in: storageProvider.persistentContainer.viewContext, ofType: .wateringTaskType)

        XCTAssertNotNil(careInfoItem.id)
        XCTAssertNotNil(careInfoItem.creationDate)

        XCTAssertNotNil(careInfoItem.nextReminder)
        XCTAssertNil(careInfoItem.lastCompletedReminder)

        XCTAssertNil(careInfoItem.currentSchedule)
        XCTAssertNotNil(careInfoItem.careCategory)
    }

    func testUpdateNextCareDate_whenTaskIsNew_andIntervalIsDaily_NextDateIsToday() throws {
        let careInfoItem = try CareInfo.createDefaultInfoItem(in: storageProvider.persistentContainer.viewContext, ofType: .wateringTaskType)
        let dailySchedule = CareSchedule.dailySchedule(interval: 1, context: storageProvider.persistentContainer.viewContext)
        try careInfoItem.setSchedule(to: dailySchedule)

        let today = Calendar.current.startOfDay(for: Date())

        XCTAssertNotNil(careInfoItem.nextCareDate)
        XCTAssertEqual(careInfoItem.nextCareDate, today)
    }

    func testUpdateNextCareDate_whenTaskIsNew_andIntervalIsWeekly_NextDateIsNextInInterval() throws {
        let careInfoItem = try CareInfo.createDefaultInfoItem(in: storageProvider.persistentContainer.viewContext, ofType: .wateringTaskType)
        let weekday = 1
        let weeklySchedule = CareSchedule.weeklySchedule(daysOfTheWeek: [weekday], context: storageProvider.persistentContainer.viewContext)
        try careInfoItem.setSchedule(to: weeklySchedule)

        let nextCareDate = try XCTUnwrap(careInfoItem.nextCareDate)
        let today = Calendar.current.startOfDay(for: Date())
        XCTAssertTrue(nextCareDate >= today)

        let resultingWeekday = Calendar.current.component(.weekday, from: nextCareDate)
        XCTAssertEqual(resultingWeekday, weekday)
    }

    func testUpdateNextCareDate_whenTaskHasALog_andLogDateIsToday_NextDateIsNextInInterval() throws {
        let expectation = expectation(description: "Update task completion status")
        let task = try CareInfo.createDefaultInfoItem(in: storageProvider.persistentContainer.viewContext, ofType: .wateringTaskType)

        let dailySchedule = CareSchedule.dailySchedule(interval: 1, context: storageProvider.persistentContainer.viewContext).self
        try task.setSchedule(to: dailySchedule)

        try task.markAsComplete() {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)

        let lastLogDate = try XCTUnwrap(task.lastLogDate)
        let nextCareDate = try XCTUnwrap(task.nextCareDate)

        let expectedNextDate = Calendar.current.startOfDay(for: lastLogDate.addingTimeInterval(1*24*60*60))
        XCTAssertEqual(nextCareDate, expectedNextDate)
    }

    func testUpdateNextCareDate_whenTaskHasALog_andNextDateAfterLogDateIsBeforeToday_NextDateIsToday() throws {
        let task = try CareInfo.createDefaultInfoItem(in: storageProvider.persistentContainer.viewContext, ofType: .wateringTaskType)
        let dailySchedule = CareSchedule.dailySchedule(interval: 1, context: storageProvider.persistentContainer.viewContext)
        try task.setSchedule(to: dailySchedule)

        let lastDate = Date().addingTimeInterval(-4*24*60*60)
        task.nextReminder.markAs(.complete)
        task.lastCompletedReminder?.statusDate = lastDate
        task.nextReminder.scheduledDate = task.currentSchedule?.recurrenceRule?.nextDate(after: lastDate)

        let today = Calendar.current.startOfDay(for: Date())
        XCTAssertTrue(task.nextCareDate! < today)

        let nextDate = today.addingTimeInterval(1*24*60*60)
        task.markAsComplete()
        XCTAssertEqual(task.nextCareDate!, nextDate)
    }

    func testMarkAsCompleted() throws {
        let firstUpdateExpectation = expectation(description: "Update task completion status")
        let task = try CareInfo.createDefaultInfoItem(in: storageProvider.persistentContainer.viewContext, ofType: .wateringTaskType)
        let dailySchedule = CareSchedule.dailySchedule(interval: 1, context: storageProvider.persistentContainer.viewContext)
        try task.setSchedule(to: dailySchedule)

        XCTAssertNil(task.lastLogDate)

        task.markAsComplete() {
            firstUpdateExpectation.fulfill()
        }
        waitForExpectations(timeout: 5)

        let secondUpdateExpectation = expectation(description: "Update task completion status again")
        let lastLogDate = try XCTUnwrap(task.lastLogDate)

        task.markAsComplete() {
            secondUpdateExpectation.fulfill()
        }
        waitForExpectations(timeout: 5)
        let newLogDate = try XCTUnwrap(task.lastLogDate)
        XCTAssertTrue(newLogDate > lastLogDate)
    }
}
