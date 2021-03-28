//
//  OutlineImageCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/24/21.
//

import UIKit

class OutlineImageCell: UICollectionViewCell {
    static let reuseIdentifier = "OutlineImageCellReuseIdentifier"
    
    var imageView = UIImageView(frame: .zero)
    private var background = UIView()
    
    override var tintColor: UIColor! {
        didSet {
            configureCellBackgroundColor()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureBackground()
        configureImageView()
        configureCellBackgroundColor()
        configureHiearchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureBackground() {
        background.alpha = 0.5
        background.layer.cornerRadius = 10
    }
    
    private func configureImageView() {
        imageView.contentMode = .scaleAspectFit
    }
    
    private func configureCellBackgroundColor() {
        background.backgroundColor = tintColor
        imageView.tintColor = tintColor
    }
    
    private func configureHiearchy() {
        contentView.addSubview(background)
        background.frame = contentView.frame
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.heightAnchor)
        ])
    }
    
    override func prepareForReuse() {
        tintColor = .systemGroupedBackground
    }
}
