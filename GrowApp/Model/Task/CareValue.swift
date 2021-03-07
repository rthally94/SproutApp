//
//  CareValue.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/5/21.
//

import Foundation

enum CareValue<T: Hashable>: Hashable, CustomStringConvertible {
    case text(String)
    case value1(T)
    case value2(T, T)
    
    var description: String {
        switch self {
        case let .text(value): return value
        case let .value1(value):
            return String(describing: value)
        case let .value2(value1, value2):
            return String(describing: value1) + " - " + String(describing: value2)
        }
    }
}
