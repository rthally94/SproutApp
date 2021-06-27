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
        get { cardView.plantIconView.configuration?.image }
        set {
            var configuration = cardView.plantIconView.defaultConfiguration()
            configuration.image = newValue
            cardView.plantIconView.configuration = configuration
        }
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

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = 20
        clipsToBounds = true

        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 2.5
        layer.shadowOpacity = 0.2
    }

    private func setupViews() {
        backgroundColor = .secondarySystemGroupedBackground
        contentView.layoutMargins = .init(top: 10, left: 10, bottom: 10, right: 10)

        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.pinToLayoutMarginsOf(contentView)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        image = nil
        text = nil
    }
}
