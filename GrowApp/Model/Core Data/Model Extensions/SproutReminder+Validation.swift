//
//  SproutReminder+Validation.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/29/21.
//

import Foundation

extension SproutReminder {
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

    func isScheduledDateValid() -> Bool {
        if schedule != nil {
            return scheduledDate != nil
        } else {
            return scheduledDate == nil
        }
    }

    func isStatusDateValid() -> Bool {
        switch status {
        case .complete:
            return statusDate != nil
        default:
            return statusDate == nil
        }
    }

    func isStatusTypeValid() -> Bool {
        guard let statusType = statusType else { return false }
        return SproutReminderStatus(rawValue: statusType) != nil
    }

    func isCareInfoValid() -> Bool {
        careInfo != nil
    }

    func isValid() -> Bool {
        isIDValid()
        && isCreationDateValid()
        && isLastModifiedDateValid()
        && isScheduledDateValid()
        && isStatusTypeValid()
        && isStatusTypeValid()
        && isCareInfoValid()
    }
}
