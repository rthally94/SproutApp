//
//  CircleButtonCollectionViewCell.swift
//  Sprout
//
//  Created by Ryan Thally on 6/11/21.
//

import UIKit

class CircleButtonCollectionViewCell: UICollectionViewCell {
    private var button = SproutCapsuleButton()

    var title: String? {
        get {
            button.title(for: .normal)
        }

        set {
            button.setTitle(newValue, for: .normal)
        }
    }

    override var isSelected: Bool {
        get { button.isSelected }
        set { button.isSelected = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        button.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button)
        button.pinToBoundsOf(contentView)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        button.isSelected = false
        button.isHighlighted = false

        button.setTitle(nil, for: .normal)
    }
}
