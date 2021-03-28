//
//  String+Extensions.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/27/21.
//

import Foundation

extension String {
    func sentenceCase() -> String {
        let first = String(self.prefix(1).capitalized)
        let rest = String(self.dropFirst())
        return first + rest
    }
}
