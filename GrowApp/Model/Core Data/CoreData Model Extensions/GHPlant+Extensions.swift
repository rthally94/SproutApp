//
//  GHPlant+Extensions.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/1/21.
//

import Foundation

extension GHPlant {
    var tasks: Set<GHTask> {
        get { tasks_ as? Set<GHTask> ?? [] }
        set { tasks_ = newValue as NSSet }
    }
}
