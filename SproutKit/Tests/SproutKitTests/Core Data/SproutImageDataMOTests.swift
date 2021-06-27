//
//  File.swift
//  
//
//  Created by Ryan Thally on 6/23/21.
//

import CoreData
import XCTest
@testable import SproutKit

final class SproutImageDataMOTests: CoreDataTestCase {
    // MARK: - Managed Object LifeCycle
    func test_WhenImageDataIsInserted_MetadataPropertiesAndInitialValuesAreSet() throws {
        let sut = SproutImageDataMO(context: moc)

        // Metadata
        let now = Date()
        let creationDate = try XCTUnwrap(sut.creationDate)
        XCTAssertEqual(creationDate.timeIntervalSinceReferenceDate, now.timeIntervalSinceReferenceDate, accuracy: 0.001)
        let lastModifiedDate = try XCTUnwrap(sut.lastModifiedDate)
        XCTAssertEqual(lastModifiedDate.timeIntervalSinceReferenceDate, now.timeIntervalSinceReferenceDate, accuracy: 0.001)
        XCTAssertNotNil(sut.id)

        // Inital Values
        XCTAssertNil(sut.rawData)
    }

    func test_WhenImageDataIsSaved_MetadataIsUpdated() {
        let sut = makeSUT()

        func saveImageData() throws {
            try self.moc.save()
            let now = Date()
            let lastModifiedDate = try XCTUnwrap(sut.lastModifiedDate)
            XCTAssertEqual(lastModifiedDate.timeIntervalSinceReferenceDate, now.timeIntervalSinceReferenceDate, accuracy: 0.001)
        }

        sleep(1)

        XCTAssertNoThrow(try saveImageData())
    }

    // MARK: - Helpers
    private func makeSUT() -> SproutImageDataMO {
        let plantTemplate = SproutPlantTemplate(scientificName: "SCIENTIFIC_NAME", commonName: "COMMON_NAME")
        let plant = SproutPlantMO.insertNewPlant(using: plantTemplate, into: moc)

        let imageData = SproutImageDataMO(context: moc)
        imageData.rawData = UIImage(systemName: "star.fill")?.pngData()

        plant.fullImageData = imageData
        imageData.plant = plant


        return imageData
    }
}
