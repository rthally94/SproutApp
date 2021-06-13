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
        imageView.isHidden = true

        let huggingPriority = imageView.contentHuggingPriority(for: .horizontal) + 1
        imageView.setContentHuggingPriority(huggingPriority, for: .horizontal)

        return imageView
    }()

    lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        textLabel.isHidden = true
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

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setImage(_ newImage: UIImage?) {
        if newImage != imageView.image {
            imageView.image = newImage

            imageView.isHidden = newImage == nil
        }
    }

    func setTitle(_ newTitle: String?) {
        if newTitle != textLabel.text {
            textLabel.text = newTitle

            textLabel.isHidden = newTitle == nil
        }
    }
}

extension CollectionViewHeader {
    func configureHiearchy() {
        let stack = UIStackView(arrangedSubviews: [imageView, textLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8

        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        layoutMargins = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
        ])
    }
}
