//
//  File.swift
//  
//
//  Created by Ryan Thally on 6/21/21.
//

import CoreData
import XCTest
@testable import SproutKit

final class SproutCareTaskMOTests: CoreDataTestCase {
    // MARK: - Managed Object LifeCycle
    func test_WhenTaskIsInserted_MetadataPropertiesAndInitialValuesAreSet() throws {
        let sut = SproutCareTaskMO(context: moc)

        // Metadata
        let now = Date()
        let creationDate = try XCTUnwrap(sut.creationDate)
        XCTAssertEqual(creationDate.timeIntervalSinceReferenceDate, now.timeIntervalSinceReferenceDate, accuracy: 0.001)
        let lastModifiedDate = try XCTUnwrap(sut.lastModifiedDate)
        XCTAssertEqual(lastModifiedDate.timeIntervalSinceReferenceDate, now.timeIntervalSinceReferenceDate, accuracy: 0.001)
        XCTAssertNotNil(sut.id)

        // Inital Values
        XCTAssertFalse(sut.hasSchedule)
        XCTAssertNil(sut.dueDate)

        XCTAssertFalse(sut.hasRecurrenceRule)
        XCTAssertNil(sut.recurrenceFrequency)
        XCTAssertEqual(sut.recurrenceInterval, 1)
        XCTAssertNil(sut.recurrenceDaysOfWeek)
        XCTAssertNil(sut.recurrenceDaysOfMonth)

        XCTAssertEqual(sut.status, SproutMarkStatus.due.rawValue)
        XCTAssertNil(sut.statusDate)
    }

    func test_WhenTaskIsSaved_MetadataIsUpdated() {
        let sut = makeSUT().first!

        func saveTask() throws {
            try self.moc.save()
            let now = Date()
            let lastModifiedDate = try XCTUnwrap(sut.lastModifiedDate)
            XCTAssertEqual(lastModifiedDate.timeIntervalSinceReferenceDate, now.timeIntervalSinceReferenceDate, accuracy: 0.001)
        }

        sleep(1)

        XCTAssertNoThrow(try saveTask())
    }

    func test_WhenTaskIsInsertedWithTemplate_ItIsAssociatedWithTheCareInformationMatchingTheTemplate() throws {
        let type = SproutCareType.watering
        let sut = SproutCareTaskMO.insertNewTask(of: type, into: moc)

        let info = try XCTUnwrap(sut.careInformation)
        XCTAssertEqual(info.type, type.rawValue)
    }

    // MARK: - Fetch Requests
    func test_UpNextFetchRequest_WhenIncludesCompletedIsFalse_ResultOnlyIncludesDueTasks() {
        let taskCount = 4
        let doneCount = 1
        let expectedCount = taskCount - doneCount

        let sut = makeSUT(taskCount: taskCount, doneCount: doneCount)
        XCTAssertNoThrow(try moc.save())

        func fetchTaskCount() throws {
            let request = SproutCareTaskMO.upNextFetchRequest(includesCompleted: false)
            let fetchedCount = try moc.count(for: request)
            XCTAssertEqual(fetchedCount, expectedCount)
        }
        XCTAssertNoThrow(try fetchTaskCount())

        func fetchTasks() throws {
            let request = SproutCareTaskMO.upNextFetchRequest(includesCompleted: false)
            let fetchedTasks = try moc.fetch(request)

            let allMatch = fetchedTasks.allSatisfy { fetchedTask in
                sut.contains(fetchedTask)
            }

            XCTAssertTrue(allMatch)
        }
        XCTAssertNoThrow(try fetchTasks())
    }

    func test_UpNextFetchRequest_WhenIncludesCompletedIsTrue_CompletedTasks() {
        let taskCount = 4
        let doneCount = 1
        let expectedCount = taskCount

        let sut = makeSUT(taskCount: taskCount, doneCount: doneCount)
        XCTAssertNoThrow(try moc.save())

        func fetchTaskCount() throws {
            let request = SproutCareTaskMO.upNextFetchRequest(includesCompleted: true)
            let fetchedCount = try moc.count(for: request)
            XCTAssertEqual(fetchedCount, expectedCount)
        }
        XCTAssertNoThrow(try fetchTaskCount())

        func fetchTasks() throws {
            let request = SproutCareTaskMO.upNextFetchRequest(includesCompleted: true)
            let fetchedTasks = try moc.fetch(request)

            let allMatch = fetchedTasks.allSatisfy { fetchedTask in
                sut.contains(fetchedTask)
            }

            XCTAssertTrue(allMatch)
        }
        XCTAssertNoThrow(try fetchTasks())
    }

    func test_RemindersFetchRequest_ResultIsAllDueTasksGroupedByDueDate() {
        let taskCount = 4
        let scheduledCount = 2
        let doneCount = 1
        let expectedCount = scheduledCount - doneCount

        let _ = makeSUT(taskCount: taskCount, scheduledCount: scheduledCount, doneCount: doneCount)
        XCTAssertNoThrow(try moc.save())

        func fetchTaskCount() throws {
            let request = SproutCareTaskMO.remindersFetchRequest()
            let result = try moc.count(for: request)

            XCTAssertEqual(expectedCount, result)
        }
        XCTAssertNoThrow(try fetchTaskCount())
    }

    // MARK: - Swift Properties
    func test_SettingSchedule_WhenInputIsNil_PropertiesAreSetCorrectly() {
        let sut = makeSUT().first!
        sut.schedule = nil

        XCTAssertFalse(sut.hasSchedule)
        XCTAssertNil(sut.startDate)
        XCTAssertEqual(sut.dueDate, sut.statusDate)
    }

    func test_SettingSchedule_WhenInputIsNotNil_PropertiesAreSetCorrectly() {
        let sut = makeSUT().first!

        let startDate = Date()
        let dueDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        sut.schedule = .init(startDate: startDate, dueDate: dueDate)

        XCTAssertTrue(sut.hasSchedule)
        XCTAssertEqual(sut.startDate, startDate)
        XCTAssertEqual(sut.dueDate, sut.statusDate)
    }

    func test_Schedule_WhenScheduleIsValid_PropertiesAreSetCorrectly() {
        let sut = makeSUT().first!
        let startDate = Date()
        let testSchedules: [SproutCareTaskSchedule?] = [
            SproutCareTaskSchedule(startDate: startDate, dueDate: Calendar.current.date(byAdding: .day, value: 2, to: startDate)!),
            SproutCareTaskSchedule(startDate: startDate, recurrenceRule: .daily(1))
        ]

        for schedule in testSchedules {
            sut.schedule = schedule

            XCTAssertEqual(sut.hasSchedule, schedule != nil)
            XCTAssertEqual(sut.schedule, schedule)
        }
    }

    func test_Schedule_WhenScheduleIsInvaidOrNil_NoPropertiesAreModified() {
        let sut = makeSUT().first!
        let startDate = Date()
        let testSchedules: [SproutCareTaskSchedule?] = [
            nil,
            SproutCareTaskSchedule(startDate: startDate, dueDate: Calendar.current.date(byAdding: .day, value: -2, to: startDate)!),
            SproutCareTaskSchedule(startDate: startDate, recurrenceRule: .weekly(2)),
            SproutCareTaskSchedule(startDate: startDate, recurrenceRule: .monthly(2)),
            SproutCareTaskSchedule(startDate: startDate, dueDate: Calendar.current.date(byAdding: .day, value: 2, to: startDate)!, recurrenceRule: .daily(5))
        ]

        for schedule in testSchedules {
            sut.schedule = schedule

            XCTAssertEqual(sut.schedule, schedule)
        }
    }

    func test_SettingSchedule_WhenStatusIsDone_NoChangesAreMade() {
        let sut = makeSUT().first!
        let startDate = Date()
        let dueDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        sut.schedule = .init(startDate: startDate, dueDate: dueDate)
        sut.markStatus = .done

        let newDueDate = Calendar.current.date(byAdding: .day, value: 3, to: startDate)!
        sut.schedule = .init(startDate: startDate, dueDate: newDueDate)

        XCTAssertEqual(sut.dueDate, dueDate)
    }

    func test_GettingSchedule_WhenTaskHasNoSchedule_NilIsReturned() {
        let sut = makeSUT().first!

        XCTAssertNil(sut.schedule)
    }

    func test_GettingSchedule_WhenTaskHasASchedule_AScheduleIsReturnedWithMatchingProperties() throws {
        let sut = makeSUT(scheduledCount: 1).first!

        let schedule = try XCTUnwrap(sut.schedule)
        XCTAssertEqual(schedule.startDate, sut.startDate)
        XCTAssertEqual(schedule.dueDate, sut.dueDate)
        XCTAssertEqual(schedule.recurrenceRule, sut.recurrenceRule)
    }

    func test_RecurrenceRule_PropertiesAreSetCorrectly() {
        let sut = makeSUT().first!

        let testRules: [SproutCareTaskRecurrenceRule] = [
            .daily(1),
            .weekly(1, [2,4,6]),
            .monthly(1, [1,15])
        ]

        func testRecurrenceRules() throws {
            for rule in testRules {
                let testSchedule = SproutCareTaskSchedule(startDate: Date(), recurrenceRule: rule)
                sut.schedule = testSchedule

                let recurrenceRule = try XCTUnwrap(sut.recurrenceRule)
                XCTAssertEqual(recurrenceRule, rule)
            }
        }

        XCTAssertNoThrow(try testRecurrenceRules())
    }

    func test_MarkAsComplete_WhenTaskIsNotScheduled_TaskIsMarkedAsDone_AndNewTaskIsAdded() {
        let sut = makeSUT().first!
        sut.markAsComplete()

        func fetchNewTask() throws {
            let request = SproutCareTaskMO.dueTasksFetchRequest(plant: sut.plant, careType: sut.careInformation?.careType)
            let newTask = try moc.fetch(request).first
            XCTAssertNotEqual(newTask, sut)
        }

        XCTAssertEqual(sut.markStatus, .done)
        XCTAssertNoThrow(try fetchNewTask())
    }


    // MARK: - Helpers
    private func makeSUT(taskCount: Int = 1, scheduledCount: Int = 0, doneCount: Int = 0) -> [SproutCareTaskMO] {
        return Array(0..<taskCount).map { index in
            let task = createSavableTask(id: index)
            if scheduledCount-1 >= index {
                let recurrenceRule = SproutCareTaskRecurrenceRule.daily(index + 1)
                task.schedule = .init(startDate: Date(), recurrenceRule: recurrenceRule)
            }

            if doneCount-1 >= index {
                task.markStatus = .done
            }

            return task
        }
    }

    private func createSavableTask(id: Int = 0) -> SproutCareTaskMO {
        let task = SproutCareTaskMO(context: moc)
        let careInformation = SproutCareInformationMO.fetchOrInsertCareInformation(of: .watering, in: moc)
        task.careInformation = careInformation

        let plantTemplate = SproutPlantTemplate(scientificName: "SCIENTIFIC_NAME", commonName: "COMMON_NAME")
        let plant = SproutPlantMO.insertNewPlant(using: plantTemplate, into: moc)

        careInformation.plant = plant
        task.plant = plant

        return task
    }
}

