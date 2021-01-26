//
//  CareInfoHeaderCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/25/21.
//

import UIKit

class CareInfoHeaderCell: FormCell {
    var accessoryButton = UIButton(type: .close)
    
    convenience init(image: UIImage?, title: String) {
        self.init(style: .default, reuseIdentifier: nil)
        
        self.imageView!.image = image
        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
        imageView?.preferredSymbolConfiguration = symbolConfiguration
        
        self.textLabel!.text = title
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(accessoryButton)
        accessoryButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addConstraints([
            accessoryButton.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            accessoryButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            accessoryButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: 10),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
