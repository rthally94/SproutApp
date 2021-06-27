//
//  UserDefaults+Extensions.swift
//  Sprout
//
//  Created by Ryan Thally on 6/7/21.
//

import Foundation

extension UserDefaults {
    enum Keys: String {
        case hasLaunched
        case dailyDigestIsEnabled
        case dailyDigestDate
    }

    func bool(forKey key: Keys) -> Bool {
        return bool(forKey: key.rawValue)
    }

    func string(forKey key: Keys) -> String? {
        return string(forKey: key.rawValue)
    }

    func object(forKey key: Keys) -> Any? {
        return object(forKey: key.rawValue)
    }

    func setValue(_ newValue: Any?, forKey key: Keys) {
        setValue(newValue, forKey: key.rawValue)
    }
}
