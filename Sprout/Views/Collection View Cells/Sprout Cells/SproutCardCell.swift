//
//  CardCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/27/21.
//

import UIKit

class SproutCardCell: UICollectionViewCell {
    var cardView = SproutCardView()

    var image: UIImage? {
        get { cardView.imageView.image }
        set { cardView.imageView.image = newValue }
    }

    var text: String? {
        get { cardView.textLabel.text }
        set { cardView.textLabel.text = newValue }
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

        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 2.5
        layer.shadowOpacity = 0.2
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        image = nil
        text = nil
    }
}
