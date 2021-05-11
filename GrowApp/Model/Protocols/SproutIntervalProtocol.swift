//
//  SproutIntervalProtocol.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/11/21.
//

import Foundation

protocol SproutIntervalProtocol {
    // daily, weekly, monthly
    var frequency: SproutRecurrenceFrequency { get set }

    // every 2 days, every 3 weeks, every 4 months
    var interval: Int { get set }

    var firstDayOfTheWeek: Int { get set }
    var daysOfTheWeek: Set<Int>? { get set }
    var daysOfTheMonth: Set<Int>? { get set }
}
