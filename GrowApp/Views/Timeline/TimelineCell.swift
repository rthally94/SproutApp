//
//  TimelineCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/18/21.
//

import UIKit

class TimelineCell: UICollectionViewCell {
    static let reuseIdentifier = "TimelineCellReuseIdentifier"
    let divider = DividerView()
    
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    var textStack: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureTitleLabel()
        configureSubtitleLabel()
        configureTextStack()
        configureHiearchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    }
    
    private func configureHiearchy() {
        divider.translatesAutoresizingMaskIntoConstraints = false
        textStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(divider)
        addSubview(textStack)
        
        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(equalTo: topAnchor),
            divider.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            textStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            textStack.leadingAnchor.constraint(equalToSystemSpacingAfter: divider.trailingAnchor, multiplier: 1.0),
            textStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            textStack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
}
