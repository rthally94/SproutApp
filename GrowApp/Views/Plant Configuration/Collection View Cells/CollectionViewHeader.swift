//
//  CollectionViewHeader.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/18/21.
//

import UIKit

class CollectionViewHeader: UICollectionReusableView {
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        let huggingPriority = imageView.contentHuggingPriority(for: .horizontal) + 1
        imageView.setContentHuggingPriority(huggingPriority, for: .horizontal)
        return imageView
    }()

    lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        return textLabel
    }()

    lazy var accessoryButton: UIButton = {
        let accessoryButton = UIButton(type: .system)
        accessoryButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        accessoryButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        let huggingPriority = accessoryButton.contentHuggingPriority(for: .horizontal) + 1
        accessoryButton.setContentHuggingPriority(huggingPriority, for: .horizontal)
        return accessoryButton
    }()

    var onTap: (() -> Void)?

    @objc private func buttonTapped() {
        onTap?()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureHiearchy()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CollectionViewHeader {
    func configureHiearchy() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        addSubview(textLabel)

        layoutMargins = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)

        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: layoutMarginsGuide.centerYAnchor),
            imageView.heightAnchor.constraint(equalTo: layoutMarginsGuide.heightAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),

            textLabel.firstBaselineAnchor.constraint(equalTo: imageView.firstBaselineAnchor),
            textLabel.lastBaselineAnchor.constraint(equalTo: imageView.lastBaselineAnchor),
            textLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: imageView.trailingAnchor, multiplier: 1.0),
            textLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        ])
    }
}
