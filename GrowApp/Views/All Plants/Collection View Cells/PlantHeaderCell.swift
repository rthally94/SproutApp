//
//  PlantHeaderCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/4/21.
//

import UIKit

class PlantHeaderCell: UICollectionViewCell {
    lazy var plantIconView = PlantIconView()
    
    lazy var plantNameLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        return view
    }()
    
    lazy var plantTypeLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.preferredFont(forTextStyle: .headline)
        view.tintColor = view.tintColor.withAlphaComponent(0.7)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHiearchy()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureHiearchy() {
        plantIconView.translatesAutoresizingMaskIntoConstraints = false
        plantNameLabel.translatesAutoresizingMaskIntoConstraints = false
        plantTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(plantIconView)
        contentView.addSubview(plantNameLabel)
        contentView.addSubview(plantTypeLabel)
        
        NSLayoutConstraint.activate([
            plantIconView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            plantIconView.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor, multiplier: 0.5),
            plantIconView.heightAnchor.constraint(equalTo: plantIconView.widthAnchor),
            plantIconView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            
            plantNameLabel.topAnchor.constraint(equalToSystemSpacingBelow: plantIconView.bottomAnchor, multiplier: 2.0),
            plantNameLabel.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            plantNameLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.widthAnchor),
            
            plantTypeLabel.topAnchor.constraint(equalToSystemSpacingBelow: plantNameLabel.bottomAnchor, multiplier: 1.0),
            plantTypeLabel.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            plantTypeLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.widthAnchor),
            plantTypeLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }
}
