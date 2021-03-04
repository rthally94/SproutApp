//
//  CareInfoCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/4/21.
//

import UIKit

class CareInfoCell: UICollectionViewCell {
    lazy var careTypeIconView: UIImageView = {
        let view = UIImageView()
        
        setContentHuggingPriority(.defaultLow + 1, for: .horizontal)
        return view
    }()
    
    lazy var careTypeLabel: UILabel = {
        let view = UILabel()
        
        return view
    }()
    
    lazy var careDetailLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHiearchy()
        backgroundColor = .quaternarySystemFill
        layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureHiearchy() {
        careTypeIconView.translatesAutoresizingMaskIntoConstraints = false
        careTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        careDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(careTypeIconView)
        contentView.addSubview(careTypeLabel)
        contentView.addSubview(careDetailLabel)
        
        NSLayoutConstraint.activate([
            careTypeIconView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            careTypeIconView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            
            careTypeLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            careTypeLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: careTypeIconView.trailingAnchor, multiplier: 1.0),
            careTypeLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            careDetailLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            careDetailLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            careDetailLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            careDetailLabel.topAnchor.constraint(greaterThanOrEqualTo: careTypeLabel.bottomAnchor),
        ])
    }
}
