//
//  CareInfoCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/26/21.
//

import UIKit

class CareInfoCell: FormCell {
    var iconView = UIImageView()
    var titleLabel = UILabel()
    var valueLabel = UILabel()
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        
        iconView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .body)
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        titleLabel.textColor = tintColor
        
        valueLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        valueLabel.layer.opacity = 0.7
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        
        contentView.addConstraints([
            iconView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            iconView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            iconView.firstBaselineAnchor.constraint(equalTo: titleLabel.firstBaselineAnchor),
            iconView.lastBaselineAnchor.constraint(equalTo: titleLabel.lastBaselineAnchor),
            
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: iconView.trailingAnchor, multiplier: 1.0),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            valueLabel.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1.0),
            valueLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            valueLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
