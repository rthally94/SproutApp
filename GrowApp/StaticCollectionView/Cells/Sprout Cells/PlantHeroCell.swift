//
//  PlantHeroCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/26/21.
//

import UIKit

class PlantHeroCell: UICollectionViewCell {
    var heroView = PlantHeroView()

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

        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowOffset = .zero
        contentView.layer.shadowRadius = 5
    }
}
