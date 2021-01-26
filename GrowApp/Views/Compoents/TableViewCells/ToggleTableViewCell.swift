//
//  ToggleTableViewCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/25/21.
//

import UIKit

class ToggleTableViewCell: FormCell {
    var toggle = UISwitch(frame: .zero)
    var onToggle: (() -> ())?
    
    convenience init(image: UIImage?, title: String, onToggle: @escaping () -> () ) {
        self.init(style: .value1, reuseIdentifier: nil)
        
        self.onToggle = onToggle
        
        self.imageView!.image = image
        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
        self.imageView!.preferredSymbolConfiguration = symbolConfiguration
        
        self.textLabel!.text = title
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        toggle.addTarget(self, action: #selector(onSwitchToggle(_:)), for: .valueChanged)
        
        contentView.addSubview(toggle)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addConstraints([
            toggle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            toggle.heightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.heightAnchor),
            toggle.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onSwitchToggle(_ sender: UISwitch) {
        self.onToggle?()
    }
}
