//
//  CareInfoCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/26/21.
//

import UIKit

class CareInfoCell: FormCell {
    var valueLabel = UILabel()
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        
        guard let textLabel = textLabel else { fatalError() }
        textLabel.removeConstraints(textLabel.constraints)
        textLabel.font = UIFont.preferredFont(forTextStyle: .body)
        
        textLabel.textColor = tintColor
        
        guard let imageView = imageView else { fatalError() }
        imageView.removeConstraints(imageView.constraints)
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .body)
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        valueLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        valueLabel.layer.opacity = 0.7
        
        contentView.addSubview(valueLabel)
        
        contentView.addConstraints([
            imageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            imageView.firstBaselineAnchor.constraint(equalTo: textLabel.firstBaselineAnchor),
            imageView.lastBaselineAnchor.constraint(equalTo: textLabel.lastBaselineAnchor),
            
            textLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: imageView.trailingAnchor, multiplier: 1.0),
            textLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            valueLabel.topAnchor.constraint(equalToSystemSpacingBelow: textLabel.bottomAnchor, multiplier: 1.0),
            valueLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            valueLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
