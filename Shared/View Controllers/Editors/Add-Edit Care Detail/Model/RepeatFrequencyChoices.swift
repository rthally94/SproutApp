//
//  RepeatFrequencyChoices.swift
//  Sprout
//
//  Created by Ryan Thally on 6/10/21.
//

import Foundation
import SproutKit

enum RepeatFrequencyChoices: String, CaseIterable {
    case daily
    case weekly
    case monthly
}

extension RepeatFrequencyChoices: Equatable {
    static func ==(lhs: RepeatFrequencyChoices, rhs: SproutCareTaskRecurrenceRule) -> Bool {
        switch rhs {
        case .daily where lhs == .daily:
            return true
        case .weekly where lhs == .weekly:
            return true
        case .monthly where lhs == .monthly:
            return true
        default:
            return false
        }
    }

    static func ==(lhs: SproutCareTaskRecurrenceRule, rhs: RepeatFrequencyChoices) -> Bool {
        switch lhs {
        case .daily where rhs == .daily:
            return true
        case .weekly where rhs == .weekly:
            return true
        case .monthly where rhs == .monthly:
            return true
        default:
            return false
        }
    }
}
