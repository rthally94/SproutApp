//
//  CareCategory+Validators.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/29/21.
//

import Foundation

extension CareCategory {
    func isIDValid() -> Bool {
        id != nil
    }

    func isCreationDateValid() -> Bool {
        creationDate != nil
    }

    func isLastModifiedDateValid() -> Bool {
        lastModifiedDate != nil
    }

    func isNameValid() -> Bool {
        guard let name = name else { return false }
        return !name.isEmpty
    }

    func isIconValid() -> Bool {
        icon != nil
    }

    func isValid() -> Bool {
        isIDValid()
        && isCreationDateValid()
        && isLastModifiedDateValid()
        && isNameValid()
        && isIconValid()
    }
}

