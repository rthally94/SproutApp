//
//  PlantCardCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/27/21.
//

import UIKit

class PlantCardCell: UICollectionViewCell {
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        
        return view
    }()
    
    lazy var textLabel: UILabel = {
        let view = UILabel()
        
        return view
    }()
    
    lazy var secondaryTextLabel: UILabel = {
        let view = UILabel()
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHiearchy()
        
        backgroundColor = .secondarySystemFill
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PlantCardCell {
    func configureHiearchy() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageView)
        contentView.addSubview(textLabel)
        contentView.addSubview(secondaryTextLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            textLabel.topAnchor.constraint(greaterThanOrEqualTo: imageView.bottomAnchor, constant: 6),
            textLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            secondaryTextLabel.topAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: textLabel.bottomAnchor, multiplier: 1.0),
            secondaryTextLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            secondaryTextLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            secondaryTextLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
        ])
    }
}
