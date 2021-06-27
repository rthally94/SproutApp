//
//  SproutMarkStatus.swift
//  Sprout
//
//  Created by Ryan Thally on 6/15/21.
//

import Foundation

public enum SproutMarkStatus: String, Hashable, CustomStringConvertible {
    case due
    case done
    case late
    case skipped

    public var description: String {
        return self.rawValue
    }
}
