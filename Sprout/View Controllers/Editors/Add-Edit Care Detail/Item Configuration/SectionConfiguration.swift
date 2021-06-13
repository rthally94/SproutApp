//
//  SectionConfiguration.swift
//  Sprout
//
//  Created by Ryan Thally on 6/12/21.
//

import Foundation

struct SectionConfiguration: Hashable {
    var headerText: String?
    var footerText: String?

    var showsHeader: Bool {
        headerText != nil
    }

    var showsFooter: Bool {
        footerText != nil
    }
}

extension SectionConfiguration {
    init(header: String? = nil, footer: String? = nil) {
        self.init(headerText: header, footerText: footer)
    }
}
