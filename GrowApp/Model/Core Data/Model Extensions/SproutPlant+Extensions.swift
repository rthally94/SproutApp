//
//  GHPlant+Extensions.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/1/21.
//

import Foundation

extension SproutPlant {
    var tasks: Set<CareInfo> {
        get { careInfoItems as? Set<CareInfo> ?? [] }
        set { careInfoItems = newValue as NSSet }
    }
}
