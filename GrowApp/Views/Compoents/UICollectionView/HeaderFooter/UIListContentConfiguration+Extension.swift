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
        config.textProperties.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        config.textProperties.color = .label
        config.textProperties.transform = .capitalized
        
        config.imageProperties.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        
        config.imageToTextPadding = 5
        return config
    }
}
