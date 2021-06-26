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

        XCTAssertNotNil(sut.identifier)
    }

    func test_WhenPlantIsSaved_MetadataIsUpdated() {
        let sut = SproutPlantMO(context: moc)

        func updatePlant() throws {
            sut.commonName = "Test"
            sut.scientificName = "Test"
            sut.nickname = "Test"
            try self.moc.save()
            let now = Date()
            let lastModifiedDate = try XCTUnwrap(sut.lastModifiedDate)
            XCTAssertEqual(lastModifiedDate.timeIntervalSinceReferenceDate, now.timeIntervalSinceReferenceDate, accuracy: 0.1)
        }

        sleep(1)
        XCTAssertNoThrow(try updatePlant())
    }

    func test_WhenPlantIsInsertedWithTemplate_PropertiesAreConfiguredToMatchTemplate() {
        let template = SproutPlantTemplate(scientificName: "SCIENTIFIC_NAME", commonName: "COMMON_NAME")
        let sut = SproutPlantMO.insertNewPlant(using: template, into: moc)

        XCTAssertEqual(template.scientificName, sut.scientificName)
        XCTAssertEqual(template.commonName, sut.commonName)
    }

    func test_FetchAllPlants() {
        let plantCount = 4
        let sut = makeSUT(count: plantCount)
        XCTAssertNoThrow(try moc.saveIfNeeded())

        func fetchCount() throws {
            let request = SproutPlantMO.allPlantsFetchRequest()
            let count = try moc.count(for: request)
            XCTAssertEqual(count, plantCount)
        }

        func fetchPlants() throws {
            let request = SproutPlantMO.allPlantsFetchRequest()
            let fetchedPlants = try moc.fetch(request)
            fetchedPlants.forEach { fetchedPlant in
                XCTAssertTrue(sut.contains(fetchedPlant))
            }
        }

        XCTAssertNoThrow(try fetchCount())
        XCTAssertNoThrow(try fetchPlants())
    }

    func test_AwakeFromFetch() throws {
        let sut = makeSUT().first!
        let sutThumbnail = sut.thumbnailImageData
        XCTAssertNoThrow(try moc.saveIfNeeded())
        moc.reset()

        let testThumbnail = try XCTUnwrap(moc.existingObject(with: sut.objectID) as? SproutPlantMO).thumbnailImageData
        XCTAssertNotNil(testThumbnail)
        XCTAssertEqual(sutThumbnail, testThumbnail)
    }

    func test_getImageIntent() {
        let sut = makeSUT().first!
        let referenceImage = UIImage(systemName: "leaf.fill")?.orientedUp()
        sut.setImage(referenceImage)

        XCTAssertNotNil(sut.getImage(preferredSize: .thumbnail))
        XCTAssertNotNil(sut.getImage(preferredSize: .full))
    }

    private func makeSUT(count: Int = 1) -> [SproutPlantMO] {
        return (0..<count).map { index in
            let template = SproutPlantTemplate.sampleData[index % SproutPlantTemplate.sampleData.count]
            let newPlant = SproutPlantMO.insertNewPlant(using: template, into: moc)
            newPlant.setImage(UIImage(systemName: "star.fill"))
            return newPlant
        }
    }
}
