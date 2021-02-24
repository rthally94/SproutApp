//
//  CollectionViewHeader.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/18/21.
//

import UIKit

class CollectionViewHeader: UICollectionReusableView {
    lazy var imageView: UIView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit

        let compressionResistence = imageView.contentCompressionResistancePriority(for: .horizontal) - 1
        imageView.setContentCompressionResistancePriority(compressionResistence, for: .horizontal)
        return imageView
    }()

    lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.font = UIFont.preferredFont(forTextStyle: .headline)
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

    private lazy var headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillProportionally
        return stack
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
        headerStack.addArrangedSubview(imageView)
        headerStack.addArrangedSubview(textLabel)
        headerStack.addArrangedSubview(accessoryButton)

        layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)

        headerStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(headerStack)
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            headerStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            headerStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            headerStack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
}
