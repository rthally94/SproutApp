//
//  TextFieldTableViewCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/25/21.
//

import UIKit

class TextFieldTableViewCell: FormCell {
    var textField = UITextField(frame: .zero)
    
    convenience init(placeholder: String) {
        self.init(style: .default, reuseIdentifier: nil)
        
        textField.placeholder = placeholder
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textField.autocapitalizationType = .words
        
        contentView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addConstraints([
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textField.heightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.heightAnchor),
            textField.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
