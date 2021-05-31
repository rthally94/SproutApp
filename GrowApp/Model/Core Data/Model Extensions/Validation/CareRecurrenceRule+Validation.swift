//
//  CareRecurrenceRule+Validation.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/29/21.
//

import Foundation

extension CareRecurrenceRule {
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

    func isFrequencyValid() -> Bool {
        guard let frequency = recurrenceFrequency else { return false }
        return SproutRecurrenceFrequency(rawValue: frequency) != nil
    }

    func isIntervalValid() -> Bool {
        if frequency == .weekly || frequency == .monthly {
            return interval == 1
        } else {
            return recurrenceInterval > 0
        }
    }

    func isRecurrenceDaysOfWeekValid() -> Bool {
        if frequency == .weekly {
            guard let daysOfWeek = recurrenceDaysOfWeek else { return false }
            return daysOfWeek.allSatisfy { weekday in
                (1...7).contains(weekday)
            }
        } else {
            return daysOfTheWeek == nil
        }
    }

    func isRecurrenceDaysOfMonthValid() -> Bool {
        if frequency == .monthly {
            guard let daysOfMonth = recurrenceDaysOfMonth else { return false }
            return daysOfMonth.allSatisfy { day in
                (1...31).contains(day)
            }
        } else {
            return daysOfTheMonth == nil
        }
    }

    func isValid() -> Bool {
        let id = isIDValid()
        let creationDate = isCreationDateValid()
        let lastModifiedDate =  isLastModifiedDateValid()
        let frequency = isFrequencyValid()
        let interval = isIntervalValid()
        let daysOfWeek = isRecurrenceDaysOfWeekValid()
        let daysOfMonth = isRecurrenceDaysOfMonthValid()
        
        return id
            && creationDate
            && lastModifiedDate
            && frequency
            && interval
            && daysOfWeek
            && daysOfMonth
    }
}
