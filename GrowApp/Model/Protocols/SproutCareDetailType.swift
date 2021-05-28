//
//  Sprout.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/28/21.
//

import Foundation

protocol SproutCareDetailType {
    var name: String? { get set }
    var value: Int { get set }

    var allCareDetail: [SproutCareDetail] { get }

    // TODO: Add Properties
//    var icon: SproutIcon { get set }
}
