//
//  UIListContentConfiguration+Extension.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/17/21.
//

import UIKit

extension UIListContentConfiguration {
    static func largeGroupedHeader() -> UIListContentConfiguration {
        var config = UIListContentConfiguration.groupedHeader()
        config.textProperties.font = UIFont.preferredFont(forTextStyle: .headline)
        config.textProperties.color = .label
        config.textProperties.transform = .capitalized
        
        config.imageProperties.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .headline)
        config.imageToTextPadding = 5
        
        config.axesPreservingSuperviewLayoutMargins = .vertical
        config.directionalLayoutMargins.leading = 0
        
        config.prefersSideBySideTextAndSecondaryText = true
        return config
    }
}
