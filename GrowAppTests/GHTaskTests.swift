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
        XCTAssertNotNil(task.nextCareDate)
        XCTAssertNotNil(task.interval)
        XCTAssertNotNil(task.taskType)
    }

    func testMarkAsCompleted() throws {
        let expectation = XCTestExpectation(description: "Update task completion status")
        let task = try GHTask.defaultTask(in: storageProvider.persistentContainer.viewContext, ofType: .wateringTaskType)
        task.interval?.repeatsFrequency = "daily"
        task.interval?.repeatsValues = [1]

        task.markAsComplete() {
            XCTAssertNotNil(task.lastLogDate)

            let logDate = task.lastLogDate
            let nextDate = task.nextCareDate
            let resultDate = logDate?.addingTimeInterval(1*24*60*60)
            XCTAssertEqual(nextDate, resultDate)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }
}
