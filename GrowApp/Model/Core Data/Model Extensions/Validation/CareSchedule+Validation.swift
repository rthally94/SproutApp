//
//  CareSchedule+Validation.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/29/21.
//

import Foundation

extension CareSchedule {
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

    func isStartingDateValid() -> Bool {
        startingDate != nil
    }

    func isRecurrenceRuleValid() -> Bool {
        recurrenceRule != nil
    }

    func isRemindersVaid() -> Bool {
        // Ensure first reminder is incomplete
        return sortedRemidners().first?.status == .incomplete
    }
}
