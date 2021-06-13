//
//  Bool+XOR.swift
//  Sprout
//
//  Created by Ryan Thally on 6/11/21.
//

import Foundation

extension Bool {
    static func ^(lhs: Bool, rhs: Bool) -> Bool  {
        return lhs != rhs
    }
}
