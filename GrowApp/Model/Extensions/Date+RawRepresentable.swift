//
//  Date+RawRepresentable.swift
//  Sprout
//
//  Created by Ryan Thally on 6/7/21.
//

import Foundation

extension Date: RawRepresentable {
    public init?(rawValue: String) {
        guard let date = Date.formatter.date(from: rawValue) else { return nil }
        self = date
    }

    public var rawValue: String {
        Date.formatter.string(from: self)
    }

    public typealias RawValue = String

    private static let formatter = ISO8601DateFormatter()


}
