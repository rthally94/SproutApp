//
//  PlantCardCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/27/21.
//

import UIKit

class CardCell: UICollectionViewCell {
    lazy var iconView: IconView = {
        let view = IconView()
        return view
    }()
    
    lazy var textLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.preferredFont(forTextStyle: .callout)
        
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        view.textAlignment = .center
        return view
    }()
    
    lazy var secondaryTextLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.preferredFont(forTextStyle: .caption2)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHiearchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CardCell {
    func configureHiearchy() {
        iconView.translatesAutoresizingMaskIntoConstraints = false
        let textStack = UIStackView(arrangedSubviews: [textLabel, secondaryTextLabel])
        textStack.axis = .vertical
        textStack.distribution = .fillProportionally
        textStack.alignment = .center
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(iconView)
        contentView.addSubview(textStack)
        
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor),
            iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.6),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor, multiplier: 1.0),
            
            textStack.topAnchor.constraint(equalToSystemSpacingBelow: iconView.bottomAnchor, multiplier: 1.0),
            textStack.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            textStack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            textStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
