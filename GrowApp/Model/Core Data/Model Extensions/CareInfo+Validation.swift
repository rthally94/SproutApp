//
//  CareInfo+Validation.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/29/21.
//

import Foundation

extension CareInfo {
    func isIDValid() -> Bool {
        id != nil
    }

    func isCreationDateValid() -> Bool {
        creationDate != nil
    }

    func isLastModifiedDateValid() -> Bool {
        if !isInserted {
            return lastModifiedDate != nil
        } else {
            return true
        }
    }

    func isCareCategoryValid() -> Bool {
        careCategory != nil
    }

    func isValid() -> Bool {
        isIDValid()
        && isCreationDateValid()
        && isLastModifiedDateValid()
        && isCareCategoryValid()
    }
}
