//
//  TimelineCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/18/21.
//

import UIKit

class TimelineCell: UICollectionViewCell {
    static let reuseIdentifier = "TimelineCellReuseIdentifier"
    var imageView: UIImageView!
    
    let cellBackground = RoundedRectContainer(cornerRadius: 16, frame: .zero)
    
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    var textStack: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureImageView()
        configureTitleLabel()
        configureSubtitleLabel()
        configureTextStack()
        configureHiearchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureImageView() {
        imageView = UIImageView()
        
        let symbolConfiguration = UIImage.SymbolConfiguration.init(scale: .large)
        imageView.preferredSymbolConfiguration = symbolConfiguration
        imageView.contentMode = .center
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    private func configureTitleLabel() {
        titleLabel = UILabel()
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
    }
    
    private func configureSubtitleLabel() {
        subtitleLabel = UILabel()
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    }
    
    private func configureTextStack() {
        textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.alignment = .leading
        textStack.axis = .vertical
        textStack.distribution = .fillEqually
        
    }
    
    private func configureHiearchy() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        cellBackground.translatesAutoresizingMaskIntoConstraints = false
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(imageView)
        addSubview(cellBackground)
        addSubview(textStack)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cellBackground.leadingAnchor),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.heightAnchor, multiplier: 1),
            
            cellBackground.topAnchor.constraint(equalTo: topAnchor),
            cellBackground.leadingAnchor.constraint(equalToSystemSpacingAfter: layoutMarginsGuide.leadingAnchor, multiplier: 4),
            cellBackground.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            cellBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            textStack.topAnchor.constraint(equalTo: cellBackground.layoutMarginsGuide.topAnchor),
            textStack.leadingAnchor.constraint(equalTo: cellBackground.layoutMarginsGuide.leadingAnchor),
            textStack.trailingAnchor.constraint(equalTo: cellBackground.layoutMarginsGuide.trailingAnchor),
            textStack.bottomAnchor.constraint(equalTo: cellBackground.layoutMarginsGuide.bottomAnchor)
        ])
    }
}
