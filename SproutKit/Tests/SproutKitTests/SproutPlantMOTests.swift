//
//  SproutPlantMOTests.swift
//  
//
//  Created by Ryan Thally on 6/21/21.
//

import Foundation
import CoreData
import XCTest
@testable import SproutKit

final class SproutPlantMOTests: CoreDataTestCase {
    func test_WhenPlantIsInserted_MetadataPropertiesAreSet() throws {
        let sut = SproutPlantMO(context: moc)

        let now = Date()

        let creationDate = try XCTUnwrap(sut.creationDate)
        XCTAssertEqual(creationDate.timeIntervalSinceReferenceDate, now.timeIntervalSinceReferenceDate, accuracy: 0.1)

        let lastModifiedDate = try XCTUnwrap(sut.lastModifiedDate)
        XCTAssertEqual(lastModifiedDate.timeIntervalSinceReferenceDate, now.timeIntervalSinceReferenceDate, accuracy: 0.1)

        XCTAssertNotNil(sut.id)
    }

    func test_WhenPlantIsSaved_MetadataIsUpdated() {
        let expectation = expectation(description: "Updating property and saving")
        let sut = SproutPlantMO(context: moc)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            do {
                sut.commonName = "Test"
                sut.scientificName = "Test"
                sut.nickname = "Test"
                try self.moc.save()
                let now = Date()
                let lastModifiedDate = try XCTUnwrap(sut.lastModifiedDate)
                XCTAssertEqual(lastModifiedDate.timeIntervalSinceReferenceDate, now.timeIntervalSinceReferenceDate, accuracy: 0.1)
            } catch {
                XCTFail("\(error)")
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func test_WhenPlantIsInsertedWithTemplate_PropertiesAreConfiguredToMatchTemplate() {
        let template = SproutPlantTemplate(scientificName: "SCIENTIFIC_NAME", commonName: "COMMON_NAME")
        let sut = SproutPlantMO.insertNewPlant(using: template, into: moc)

        XCTAssertEqual(template.scientificName, sut.scientificName)
        XCTAssertEqual(template.commonName, sut.commonName)
    }
}
