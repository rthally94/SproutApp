//
//  LargeHeader.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/19/21.
//

import UIKit

class LargeHeader: UICollectionReusableView {
    static let reuseIdentifer = "LargeHeaderReuseIdentifier"
    var textLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureTextLabel()
        configureHiearchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureTextLabel() {
        textLabel = UILabel()
        textLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
    }
    
    private func configureHiearchy() {
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: topAnchor),
            textLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
