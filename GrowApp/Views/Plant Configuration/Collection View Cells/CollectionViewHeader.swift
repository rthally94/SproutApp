//
//  CollectionViewHeader.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/18/21.
//

import UIKit

class CollectionViewHeader: UICollectionReusableView {
    var textLabel: UILabel! = nil
    var accessoryButton: UIButton! = nil
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
        textLabel = UILabel()
        textLabel.font = UIFont.preferredFont(forTextStyle: .headline)

        accessoryButton = UIButton(type: .system)
        accessoryButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        accessoryButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        addSubview(textLabel)
        addSubview(accessoryButton)

        textLabel.translatesAutoresizingMaskIntoConstraints = false
        accessoryButton.translatesAutoresizingMaskIntoConstraints = false

        let accessoryHuggingPriority = accessoryButton.contentHuggingPriority(for: .horizontal) + 1
        accessoryButton.setContentHuggingPriority(accessoryHuggingPriority, for: .horizontal)

        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: accessoryButton.bottomAnchor),

            accessoryButton.topAnchor.constraint(equalTo: topAnchor),
            accessoryButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -4),
            accessoryButton.leadingAnchor.constraint(equalToSystemSpacingAfter: textLabel.trailingAnchor, multiplier: 1.0),
            accessoryButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            accessoryButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
        ])
    }
}
