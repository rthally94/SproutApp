//
//  HashableClosure.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/26/21.
//

import Foundation

struct HashableClosure<ClosureParameter>: Hashable {
    var id: String
    var action: (ClosureParameter) -> Void

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: HashableClosure<ClosureParameter>, rhs: HashableClosure<ClosureParameter>) -> Bool {
        lhs.id == rhs.id
    }
}
