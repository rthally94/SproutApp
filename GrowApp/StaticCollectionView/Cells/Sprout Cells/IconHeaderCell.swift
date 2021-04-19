//
//  PlantHeaderCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/4/21.
//

import UIKit

class IconHeaderCell: UICollectionViewCell {
    lazy var iconView = SproutIconView()

    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupViewsIfNeeded()
    }
    
    private var customViewConstraints: (
        iconViewTop: NSLayoutConstraint,
        iconViewWidth: NSLayoutConstraint
    )?
    
    func setupViewsIfNeeded() {
        guard customViewConstraints == nil else { return }
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(iconView)

        let constraints = (
            iconViewTop: iconView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            iconViewWidth: iconView.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor, multiplier: 0.3)
        )
        
        constraints.iconViewTop.priority = .required - 1
        constraints.iconViewWidth.priority = .required - 1
        
        NSLayoutConstraint.activate([
            constraints.iconViewTop,
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),
            iconView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            constraints.iconViewWidth,
            iconView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
        
        customViewConstraints = constraints
    }
}
