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

extension UserDefaults {
    @objc var hasLaunched: Bool {
        get { bool(forKey: .hasLaunched) }
        set { setValue(newValue, forKey: .hasLaunched) }
    }

    @objc var dailyDigestIsEnabled: Bool {
        get { bool(forKey: .dailyDigestIsEnabled) }
        set { setValue(newValue, forKey: .dailyDigestIsEnabled)}
    }

    @objc var dailyDigestDate: Date? {
        get {
            guard let dateTimeString = string(forKey: .dailyDigestDate),
                  let dateTime = Date(rawValue: dateTimeString)
            else { return nil }
            return dateTime
        }
        set {
            setValue(newValue, forKey: .dailyDigestDate)
        }
    }
}
