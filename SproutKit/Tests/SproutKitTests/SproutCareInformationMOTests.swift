//
//  File.swift
//  
//
//  Created by Ryan Thally on 6/23/21.
//

import CoreData
import XCTest
@testable import SproutKit

final class SproutCareInformationMOTests: CoreDataTestCase {
    // MARK: - Managed Object LifeCycle
    func test_WhenCareInfoIsInserted_MetadataPropertiesAndInitialValuesAreSet() throws {
        let sut = SproutCareInformationMO(context: moc)

        // Metadata
        let now = Date()
        let creationDate = try XCTUnwrap(sut.creationDate)
        XCTAssertEqual(creationDate.timeIntervalSinceReferenceDate, now.timeIntervalSinceReferenceDate, accuracy: 0.001)
        let lastModifiedDate = try XCTUnwrap(sut.lastModifiedDate)
        XCTAssertEqual(lastModifiedDate.timeIntervalSinceReferenceDate, now.timeIntervalSinceReferenceDate, accuracy: 0.001)
        XCTAssertNotNil(sut.identifier)

        // Inital Values
        XCTAssertFalse(sut.hasNotes)
        XCTAssertNil(sut.notes)
        XCTAssertNil(sut.icon)
        XCTAssertNil(sut.tintColor_hex)
        XCTAssertNil(sut.type)
    }

    func test_WhenCareInfoIsSaved_MetadataIsUpdated() {
        let sut = makeSUT()

        func saveTask() throws {
            try self.moc.save()
            let now = Date()
            let lastModifiedDate = try XCTUnwrap(sut.lastModifiedDate)
            XCTAssertEqual(lastModifiedDate.timeIntervalSinceReferenceDate, now.timeIntervalSinceReferenceDate, accuracy: 0.01)
        }

        sleep(1)

        XCTAssertNoThrow(try saveTask())
    }

    func test_WhenCareInfoIsInsertedWithTemplate_ItIsAssociatedWithTheCareInformationMatchingTheTemplate() throws {
        let type = SproutCareType.watering
        let sut = SproutCareInformationMO.fetchOrInsertCareInformation(of: type, in: moc)

        let info = try XCTUnwrap(sut.type)
        XCTAssertEqual(info, type.rawValue)
    }

    func test_WhenCareInfoIsInsertedUsingTemplate_AndThePlantDoesNotContainTheTask_ANewTaskIsCreated() {
        let plantTemplate = SproutPlantTemplate(scientificName: "SCIENTIFIC_NAME", commonName: "COMMON_NAME")
        let plant = SproutPlantMO.insertNewPlant(using: plantTemplate, into: moc)

        let sut = SproutCareInformationMO.fetchOrInsertCareInformation(of: .watering, for: plant, in: moc)

        XCTAssertEqual(sut.plant, plant)
        XCTAssertEqual(sut.type, SproutCareType.watering.rawValue)
    }

    func test_WhenCareInfoIsInsertedUsingTemplate_AndThePlantContainsExistingCareInfo_TheExistingInfoIsReturned() {
        let plantTemplate = SproutPlantTemplate(scientificName: "SCIENTIFIC_NAME", commonName: "COMMON_NAME")
        let plant = SproutPlantMO.insertNewPlant(using: plantTemplate, into: moc)

        let firstInfo = SproutCareInformationMO.fetchOrInsertCareInformation(of: .watering, for: plant, in: moc)
        let secondInfo = SproutCareInformationMO.fetchOrInsertCareInformation(of: .watering, for: plant, in: moc)
        XCTAssertEqual(firstInfo, secondInfo)
    }


    // MARK: - Helpers
    private func makeSUT() -> SproutCareInformationMO {
        let info = SproutCareInformationMO(context: moc)

        let plantTemplate = SproutPlantTemplate(scientificName: "SCIENTIFIC_NAME", commonName: "COMMON_NAME")
        info.plant = SproutPlantMO.insertNewPlant(using: plantTemplate, into: moc)
        return info
    }
}
