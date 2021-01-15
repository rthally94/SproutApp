//
//  PlantTests.swift
//  GrowAppTests
//
//  Created by Ryan Thally on 1/15/21.
//

import XCTest
@testable import GrowApp

class PlantTests: XCTestCase {
    func test_whenPlantIsIntialized_UUIDIsSet() {
        let sut1 = Plant()
        let sut2 = Plant()
        
        XCTAssertNotEqual(sut1.id, sut2.id)
    }
    
    func test_whenPlantIsInitialized_careDatesIsEmpty() {
        let sut = Plant()
        
        XCTAssertTrue(sut.careDates.isEmpty)
    }
    
    func test_whenCareDatesIsEmpty_andACareDateIsAdded_careDatesEquals1() {
        let sut = Plant()
        
        sut.logCare()
        
        XCTAssertEqual(sut.careDates.count, 1)
    }
    
    func test_nextCareDate_whenCareDatesisEmpty_NextCareDateIsStartOfDayForToday() {
        let sut = Plant()
        
        let expectedResult = Calendar.current.startOfDay(for: Date())
        
        XCTAssertEqual(sut.nextCareDate, expectedResult)
    }
    
    func test_nextCareDate_whenLastCareDateIsToday_NextCareDateIsStartOfDayForTomorrow() throws {
        let sut = Plant()
        sut.logCare()
        
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)
        let expectedResult = try XCTUnwrap(tomorrow)
        
        XCTAssertEqual(sut.nextCareDate, expectedResult)
    }
}
