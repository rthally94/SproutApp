//
//  GHTaskTests.swift
//  GrowAppTests
//
//  Created by Ryan Thally on 5/4/21.
//

import XCTest
@testable import GrowApp

class GHTaskTests: XCTestCase {
    var storageProvider: StorageProvider!
    
    override func setUpWithError() throws {
        storageProvider = StorageProvider(storeType: .inMemory)
    }

    func testWateringTaskInitalState() throws {
        let task = try GHTask.defaultTask(in: storageProvider.persistentContainer.viewContext, ofType: .wateringTaskType)

        XCTAssertNotNil(task.id)
        XCTAssertNil(task.lastLogDate)
        XCTAssertNil(task.nextCareDate)
        XCTAssertNotNil(task.interval)
        XCTAssertNotNil(task.taskType)
    }

    func testUpdateNextCareDate_whenTaskIsNew_andIntervalIsDaily_NextDateIsToday() throws {
        let task = try GHTask.defaultTask(in: storageProvider.persistentContainer.viewContext, ofType: .wateringTaskType)
        task.interval?.repeatsFrequency = "daily"
        task.interval?.repeatsValues = [1]
        task.updateNextCareDate()

        let today = Calendar.current.startOfDay(for: Date())

        XCTAssertNotNil(task.nextCareDate)
        XCTAssertEqual(task.nextCareDate, today)
    }

    func testUpdateNextCareDate_whenTaskIsNew_andIntervalIsWeekly_NextDateIsNextInInterval() throws {
        let task = try GHTask.defaultTask(in: storageProvider.persistentContainer.viewContext, ofType: .wateringTaskType)
        task.interval?.repeatsFrequency = GHTaskIntervalType.weekly.rawValue

        let weekday = 1
        task.interval?.repeatsValues = [weekday]
        task.updateNextCareDate()

        let nextCareDate = try XCTUnwrap(task.nextCareDate)
        let today = Calendar.current.startOfDay(for: Date())
        XCTAssertTrue(nextCareDate >= today)

        let resultingWeekday = Calendar.current.component(.weekday, from: nextCareDate)
        XCTAssertEqual(resultingWeekday, weekday)
    }

    func testUpdateNextCareDate_whenTaskHasALog_andLogDateIsToday_NextDateIsNextInInterval() throws {
        let expectation = expectation(description: "Update task completion status")
        let task = try GHTask.defaultTask(in: storageProvider.persistentContainer.viewContext, ofType: .wateringTaskType)
        task.interval?.repeatsFrequency = GHTaskIntervalType.daily.rawValue

        let days = 1
        task.interval?.repeatsValues = [days]
        task.updateNextCareDate()

        task.markAsComplete() {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)

        let lastLogDate = try XCTUnwrap(task.lastLogDate)
        let nextCareDate = try XCTUnwrap(task.nextCareDate)

        let expectedNextDate = Calendar.current.startOfDay(for: lastLogDate.addingTimeInterval(1*24*60*60))
        XCTAssertEqual(nextCareDate, expectedNextDate)
    }

    func testUpdateNextCareDate_whenTaskHasALog_andNextDateAfterLogDateIsBeforeToday_NextDateIsToday() throws {
        let task = try GHTask.defaultTask(in: storageProvider.persistentContainer.viewContext, ofType: .wateringTaskType)
        task.interval?.repeatsFrequency = GHTaskIntervalType.daily.rawValue
        let days = 1
        task.interval?.repeatsValues = [days]

        let lastDate = Date().addingTimeInterval(-4*24*60*60)
        task.lastLogDate = lastDate
        task.nextCareDate = task.interval?.nextDate(after: lastDate)

        let today = Calendar.current.startOfDay(for: Date())
        XCTAssertTrue(task.nextCareDate! < today)

        task.updateNextCareDate()
        XCTAssertEqual(task.nextCareDate!, today)
    }

    func testMarkAsCompleted() throws {
        let firstUpdateExpectation = expectation(description: "Update task completion status")
        let task = try GHTask.defaultTask(in: storageProvider.persistentContainer.viewContext, ofType: .wateringTaskType)
        task.interval?.repeatsFrequency = GHTaskIntervalType.daily.rawValue
        task.interval?.repeatsValues = [1]
        task.updateNextCareDate()

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
