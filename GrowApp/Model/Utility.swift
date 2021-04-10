//
//  Utility.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/9/21.
//

import Foundation

final class Utility { }

extension Utility {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        return formatter
    }()
}
