//
//  HashableClosure.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/26/21.
//

import Foundation

struct HashableClosure<ClosureInputType>: Hashable {
    let id: String
    let handler: (ClosureInputType) -> Void

    init(id: String = UUID().uuidString, handler: @escaping (ClosureInputType) -> Void ) {
        self.id = id
        self.handler = handler
    }


    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: HashableClosure<ClosureInputType>, rhs: HashableClosure<ClosureInputType>) -> Bool {
        lhs.id == rhs.id
    }
}
