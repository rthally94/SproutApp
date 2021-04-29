//
//  HeroCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/26/21.
//

import UIKit

class HeroCell: UICollectionViewCell {
    var heroView = HeroView()

    var image: UIImage? {
        get { heroView.imageView.image }
        set { heroView.imageView.image = newValue}
    }

    var headerTitle: String? {
        get { heroView.titleLabel.text }
        set { heroView.titleLabel.text = newValue }
    }

    var headerSubtitle: String? {
        get { heroView.subtitleLabel.text }
        set { heroView.subtitleLabel.text = newValue }
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
        contentView.addSubview(heroView)
        heroView.translatesAutoresizingMaskIntoConstraints = false
        heroView.pinToBoundsOf(contentView)

        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 5
    }
}
