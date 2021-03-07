//
//  PlantHeaderCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/4/21.
//

import UIKit

class IconHeaderCell: UICollectionViewCell {
    lazy var iconView = IconView()
    
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        return view
    }()
    
    lazy var subtitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.preferredFont(forTextStyle: .headline)
        view.tintColor = view.tintColor.withAlphaComponent(0.7)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViewsIfNeeded()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var customViewConstraints: (
        iconViewTop: NSLayoutConstraint,
        iconViewWidth: NSLayoutConstraint,
        titleLabelWidth: NSLayoutConstraint,
        subtitleLabelWidth: NSLayoutConstraint
    )?
    
    func setupViewsIfNeeded() {
        guard customViewConstraints == nil else { return }
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        let constraints = (
            iconViewTop: iconView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            iconViewWidth: iconView.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor, multiplier: 0.4),
            titleLabelWidth: titleLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.widthAnchor),
            subtitleLabelWidth: subtitleLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.widthAnchor)
        )
        
        constraints.iconViewTop.priority = .required - 1
        constraints.iconViewWidth.priority = .required - 1
        constraints.titleLabelWidth.priority = .required - 1
        constraints.subtitleLabelWidth.priority = .required - 1
        
        NSLayoutConstraint.activate([
            constraints.iconViewTop,
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),
            iconView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            constraints.iconViewWidth,
            
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: iconView.bottomAnchor, multiplier: 2.0),
            constraints.titleLabelWidth,
            titleLabel.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1.0),
            constraints.subtitleLabelWidth,
            subtitleLabel.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
        
        customViewConstraints = constraints
    }
}
