//
//  PlantTests.swift
//  GrowAppTests
//
//  Created by Ryan Thally on 1/15/21.
//

import XCTest
@testable import GrowApp

class Plant_TaskTests: XCTestCase {
    let startOfMonth = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 1))!
    
    // MARK:- Date In Interval
    func testNextCareDate_WhenIntervalIsNone_StartDateIsInInterval() {
        let sut = makeSUT(interval: .none, startingDate: startOfMonth)
        XCTAssertTrue( sut.isDateInInterval(sut.startingDate))
    }

    func testNextCareDate_WhenIntervalIsNone_DateIsInInterval() {
        let inputDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 5))!
        let sut = makeSUT(interval: .none, startingDate: startOfMonth)
        XCTAssertTrue( sut.isDateInInterval(inputDate))
    }
    
    func testNextCareDate_WhenIntervalIsDaily_StartDateIsInInterval() {
        let sut = makeSUT(interval: .daily(1), startingDate: startOfMonth)
        XCTAssertTrue( sut.isDateInInterval(sut.startingDate))
    }
    
    func testNextCareDate_WhenIntervalIsDaily_ValidDateIsInInterval() {
        let inputDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 6))!
        let sut = makeSUT(interval: .daily(5), startingDate: startOfMonth)
        let value = sut.isDateInInterval(inputDate)
        XCTAssertTrue( value )
    }
    
    func testNextCareDate_WhenIntervalIsDaily_InvalidDateIsNotInInterval() {
        let inputDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 5))!
        let sut = makeSUT(interval: .daily(5), startingDate: startOfMonth)
        let value = sut.isDateInInterval(inputDate)
        XCTAssertFalse( value )
    }
    
    func testNextCareDate_WhenIntervalIsWeeklyAndStartDateIsOnMonday_StartDateIsInInterval() {
        let weeklySUT = makeSUT(interval: .weekly([2,4,6]), startingDate: startOfMonth)
        XCTAssertTrue( weeklySUT.isDateInInterval(weeklySUT.startingDate))
    }

    func testNextCareDate_WhenIntervalIsMonthlyAndStartDateIsTheFirstOfTheMonth_StartDateIsInInterval() {
        let monthlySUT = makeSUT(interval: .monthly([1,15]), startingDate: startOfMonth)
        XCTAssertTrue( monthlySUT.isDateInInterval(monthlySUT.startingDate))
    }
    
    // MARK:- Next Care Date
    func testNextCareDate_WhenIntervalIsNone_NextCareDateIsNil() {
        let sut = makeSUT(interval: .none)
        XCTAssertNil(sut.nextCareDate(after: Date()))
    }
    
    func testNextCareDate_WhenIntervalIsDaily_NextCareDateIsAfterDateOnTheInterval() {
        let resultingDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 2))!
        let sut = makeSUT(interval: .daily(1), startingDate: startOfMonth)
        XCTAssertEqual(sut.nextCareDate(after: startOfMonth), resultingDate)
    }
    
    func testNextCareDate_WhenIntervalIsWeekly_NextCareDateIsAfterDateOnInterval() {
        let resultingDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, weekday: 4, weekOfMonth: 1))!
        let sut = makeSUT(interval: .weekly([2,4,6]), startingDate: startOfMonth)
        XCTAssertEqual(sut.nextCareDate(after: startOfMonth), resultingDate)
    }
    
    func testNextCareDate_WhenIntervalIsWeekly_AndDateIsAfterLastIntervalDay_NextCareDateIsFirstValueOfInterval() {
        let referenceDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, weekday: 7, weekOfMonth: 1))!
        let resultingDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, weekday: 2, weekOfMonth: 2))!
        let sut = makeSUT(interval: .weekly([2,4,6]), startingDate: startOfMonth)
        XCTAssertEqual(sut.nextCareDate(after: referenceDate), resultingDate)
    }
    
    func testNextCareDate_WhenIntervalIsMonthly_NextCareDateIsAfterDateOnInterval() {
        let resultingDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 15))!
        let sut = makeSUT(interval: .monthly([1,15]), startingDate: startOfMonth)
        XCTAssertEqual(sut.nextCareDate(after: startOfMonth), resultingDate)
    }
    
    func testNextCareDate_WhenIntervalIsMonthly_AndDateIsAfterLastIntervalDay_NextCareDateIsFirstValueOfInterval() {
        let referenceDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 16))!
        let resultingDate = Calendar.current.date(from: DateComponents(year: 2021, month: 4, day: 1))!
        let sut = makeSUT(interval: .monthly([1,15]), startingDate: startOfMonth)
        XCTAssertEqual(sut.nextCareDate(after: referenceDate), resultingDate)
    }
    
    // MARK:- Previous Care Date
    // None
    func testPreviousCareDate_WhenIntervalIsNone_PreviousCareDateIsNil() {
        let sut = makeSUT(interval: .none)
        XCTAssertNil(sut.previousCareDate(before: Date()))
    }
    
    // Daily
    func testPreviousCareDate_WhenIntervalIsDaily_PreviousCareDateIsBeforeDateOnTheInterval() {
        let inputDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 7))!
        let outputDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 6))!
        let sut = makeSUT(interval: .daily(1), startingDate: startOfMonth)
        XCTAssertEqual(sut.previousCareDate(before: inputDate), outputDate)
    }
    
    func testPreviousCareDate_WhenIntervalIsDaily_PreviousCareDateIsNotBeforeStartingDate() {
        let inputDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 2))!
        let sut = makeSUT(interval: .daily(2), startingDate: startOfMonth)
        XCTAssertEqual(sut.previousCareDate(before: inputDate), sut.startingDate)
    }
    
    // Weekly
    func testPreviousCareDate_WhenIntervalIsWeekly_PreviousCareDateBeforeDateOnInterval() {
        let inputDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, weekday: 4, weekOfMonth: 1))!
        let outputDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, weekday: 2, weekOfMonth: 1))!
        let sut = makeSUT(interval: .weekly([2,4,6]), startingDate: startOfMonth)
        XCTAssertEqual(sut.previousCareDate(before: inputDate), outputDate)
    }
    
    func testNextCareDate_WhenIntervalIsWeekly_AndWeekdayIsBeforeFirstIntervalDay_PreviousCareDateIsLastValueOfInterval() {
        let inputDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, weekday: 1, weekOfMonth: 2))!
        let outputDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, weekday: 6, weekOfMonth: 1))!
        let sut = makeSUT(interval: .weekly([2,4,6]), startingDate: startOfMonth)
        XCTAssertEqual(sut.previousCareDate(before: inputDate), outputDate)
    }
    
    func testPreviousCareDate_WhenIntervalIsWeekly_PreviousCareDateIsNotBeforeStartingDate() {
        let inputDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, weekday: 2, weekOfMonth: 1))!
        let sut = makeSUT(interval: .weekly([2,4,6]), startingDate: startOfMonth)
        XCTAssertEqual(sut.previousCareDate(before: inputDate), sut.startingDate)
    }
    
    // Monthly
    func testPreviousCareDate_WhenIntervalIsMonthly_PreviousCareDateIsBeforeDateOnInterval() {
        let inputDate = Calendar.current.date(from: DateComponents(year: 2021, month: 4, day: 1))!
        let outputDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 15))!
        let sut = makeSUT(interval: .monthly([1,15]), startingDate: startOfMonth)
        XCTAssertEqual(sut.previousCareDate(before: inputDate), outputDate)
    }
    
    func testPreviousCareDate_WhenIntervalIsMonthly_AndDateIsBeforeFirstIntervalDay_PreviousCareDateIsLastValueOfInterval() {
        let inputDate = Calendar.current.date(from: DateComponents(year: 2021, month: 4, day: 1))!
        let outputDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 16))!
        let sut = makeSUT(interval: .monthly([2,16]), startingDate: startOfMonth)
        XCTAssertEqual(sut.previousCareDate(before: inputDate), outputDate)
    }
    
    func testPreviousCareDate_WhenIntervalIsMonthly_PreviousCareDateIsNotBeforeStartingDate() {
        let inputDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 2))!
        let outputDate = Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 1))!
        let sut = makeSUT(interval: .monthly([2,16]), startingDate: startOfMonth)
        XCTAssertEqual(sut.previousCareDate(before: inputDate), outputDate)
    }
}

extension Plant_TaskTests {
    func makeSUT(interval: TaskInterval = .daily(1), startingDate: Date = Date()) -> Task {
        return Task(id: UUID(), type: .watering, careInfo: .text("Test"), interval: interval, startingOn: startingDate, logs: [])
    }
}
