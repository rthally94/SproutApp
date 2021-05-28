//
//  SproutCareDetail.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/28/21.
//

import Foundation

protocol SproutCareDetail {
    var notes: String? { get set }
    var careType: SproutCareDetailType? { get set }

    // TODO: Add Properties
//    var currentSchedule: SproutReminderSchedule? { get set }
//    var plant: SproutPlant? { get }
//    var allReminders: [SproutReminder] { get set }
}
