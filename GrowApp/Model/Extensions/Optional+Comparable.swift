//
//  Optional+Combarable.swift
//  GrowApp
//
//  Created by Ryan Thally on 6/3/21.
//

import Foundation

extension Optional: Comparable where Wrapped: Comparable {
    public static func < (lhs: Optional, rhs: Optional) -> Bool {
        switch (lhs, rhs) {
        case (.some, .some):
            return lhs! < rhs!
        case (.none, .some):
            return false
        case (_, .none):
            return true
        }
    }
}
