//
//  SproutCardView.swift
//  Sprout
//
//  Created by Ryan Thally on 4/28/21.
//

import UIKit

class SproutCardView: UIView {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    let textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    let blurView: UIView = {
        let view = UIView()
        view.blurBackground(style: .systemThinMaterial)
        return view
    }()

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

        blurView.clipsToBounds = true
        blurView.layer.cornerRadius = 6
    }

    private func setupViews() {
        addSubview(imageView)
        addSubview(blurView)
        blurView.addSubview(textLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        blurView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false


        imageView.pinToBoundsOf(self)
        textLabel.pinToLayoutMarginsOf(blurView)
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            blurView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            blurView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            blurView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
