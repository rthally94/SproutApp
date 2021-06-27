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
        let font = UIFont.systemFont(ofSize: 20, weight: .bold)
        config.textProperties.font = font
        config.textProperties.color = .label
        config.textProperties.transform = .capitalized
        
        config.imageProperties.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: font)
        config.imageToTextPadding = 5
        
        config.axesPreservingSuperviewLayoutMargins = .vertical
        config.directionalLayoutMargins.leading = 0
        
        config.prefersSideBySideTextAndSecondaryText = true
        return config
    }
    
    static func statisticCell() -> UIListContentConfiguration {
        var config = UIListContentConfiguration.subtitleCell()
        config.textProperties.font = UIFont.preferredFont(forTextStyle: .subheadline)
        config.textProperties.color = .label
        config.textProperties.transform = .capitalized
        
        config.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .headline)
        config.secondaryTextProperties.color = .label
        config.secondaryTextProperties.transform = .uppercase
        
        config.imageProperties.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1)
        config.imageToTextPadding = 15
        
        config.prefersSideBySideTextAndSecondaryText = false
        return config
    }
}
