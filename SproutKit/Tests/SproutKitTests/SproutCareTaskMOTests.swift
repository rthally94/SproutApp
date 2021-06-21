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
    func test_WhenTaskIsInserted_MetadataPropertiesAreSet() throws {
        let sut = SproutCareTaskMO(context: moc)

        let now = Date()

        let creationDate = try XCTUnwrap(sut.creationDate)
        XCTAssertEqual(creationDate.timeIntervalSinceReferenceDate, now.timeIntervalSinceReferenceDate, accuracy: 0.1)

        let lastModifiedDate = try XCTUnwrap(sut.lastModifiedDate)
        XCTAssertEqual(lastModifiedDate.timeIntervalSinceReferenceDate, now.timeIntervalSinceReferenceDate, accuracy: 0.1)

        XCTAssertNotNil(sut.id)
    }

    func test_WhenTaskIsSaved_MetadataIsUpdated() {
        let expectation = expectation(description: "Updating property and saving")
        let sut = makeSUT()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            do {
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

    private func makeSUT() -> SproutCareTaskMO {
        let sut = SproutCareTaskMO(context: moc)
        let careInformation = SproutCareInformationMO(context: moc)
        sut.careInformation = careInformation

        let plantTemplate = SproutPlantTemplate(scientificName: "SCIENTIFIC_NAME", commonName: "COMMON_NAME")
        let plant = SproutPlantMO.insertNewPlant(using: plantTemplate, into: moc)

        careInformation.plant = plant
        sut.plant = plant

        return sut
    }
}
