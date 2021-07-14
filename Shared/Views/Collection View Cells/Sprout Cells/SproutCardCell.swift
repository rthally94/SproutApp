//
//  CardCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/27/21.
//

import UIKit

class SproutCardCell: UICollectionViewCell {
    let cardView = SproutCardView()

    var image: UIImage? {
        get { cardView.iconConfiguration.image }
        set {
            cardView.iconConfiguration.image = newValue
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
    }

    private func setupViews() {
        backgroundColor = .secondarySystemGroupedBackground
        contentView.layoutMargins = .init(top: 10, left: 10, bottom: 10, right: 10)

        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false

        let top = cardView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor)
        let leading = cardView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor)
        let bottom = cardView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        let trailing = cardView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)

        top.priority-=1
        leading.priority-=1

        NSLayoutConstraint.activate([
            top,
            leading,
            bottom,
            trailing
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        image = nil
        text = nil
    }
}
