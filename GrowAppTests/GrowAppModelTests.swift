//
//  GrowAppTests.swift
//  GrowAppTests
//
//  Created by Ryan Thally on 1/15/21.
//

import XCTest
@testable import GrowApp

class GrowAppModelTests: XCTestCase {
    func test_whenModelIsInitialized_withNoData_getAllPlantsIsEmpty() {
        let sut = GrowAppModel.preview
        XCTAssertTrue(sut.getPlants().isEmpty)
    }
    
    func test_whenModelIsInitialized_andOnePlantIsAdded_theNewPlantIsAdded() {
        let sut = GrowAppModel.preview
        
        let newPlant = Plant()
        sut.addPlant(newPlant)
        
        XCTAssertEqual(newPlant, sut.getPlants()[0])
    }
}
