//
//  SproutPlantType+Validation.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/29/21.
//

import Foundation

extension SproutPlantType {
    func isScientificNameValid() -> Bool {
        guard let scientificName = scientificName else { return false }
        return !scientificName.isEmpty
    }

    func isCommonNameValid() -> Bool {
        guard let commonName = commonName else { return false }
        return !commonName.isEmpty
    }
}
