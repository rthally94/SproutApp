//
//  WeekPickerCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/21/21.
//

import UIKit

class WeekPickerCell: UICollectionViewCell {
    static let reuseIdentifier = "WeekPickerCellReuseIdentifier"
    
    var textLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    override func prepareForReuse() {
        textLabel.text = ""
        textLabel.font = UIFont.preferredFont(forTextStyle: .body)
        textLabel.textColor = .label
    }
}
