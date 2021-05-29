//
//  GHPlant+Validation.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/29/21.
//

import Foundation

extension GHPlant {
    func isIDValid() -> Bool {
        id != nil
    }

    func isCreationDateValid() -> Bool {
        creationDate != nil
    }

//    func isLastModifiedDateValid() -> Bool {
//        if !isInserted {
//            return lastModifiedDate != nil
//        } else {
//            return true
//        }
//    }

    func isNameValid() -> Bool {
        guard let name = name else { return false }
        return !name.isEmpty
    }

    func isIconValid() -> Bool {
        icon != nil
    }

    func isTypeValid() -> Bool {
        type != nil
    }
}
