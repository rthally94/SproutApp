//
//  CardCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/27/21.
//

import UIKit

class CardCell: UICollectionViewCell {
    var cardView = CardView()

    var image: UIImage? {
        get { cardView.imageView.image }
        set { cardView.imageView.image = newValue }
    }

    var text: String? {
        get { cardView.textLabel.text }
        set { cardView.textLabel.text = newValue }
    }

    var secondaryText: String? {
        get { cardView.secondaryTextLabel.text }
        set { cardView.secondaryTextLabel.text = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.pinToBoundsOf(contentView)

        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true

        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = .zero
        contentView.layer.shadowRadius = 5
        contentView.layer.shadowOpacity = 0.5
    }
}
