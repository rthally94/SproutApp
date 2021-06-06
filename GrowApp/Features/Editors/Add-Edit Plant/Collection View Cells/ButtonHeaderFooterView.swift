//
//  ButtonHeaderFooterView.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/24/21.
//

import UIKit

class ButtonHeaderFooterView: UICollectionReusableView {
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        return stack
    }()

    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    lazy var textLabel: UILabel = {
        let tl = UILabel()

        return tl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureHiearchy()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureHiearchy() {
        stack.addArrangedSubview(imageView)
        stack.addArrangedSubview(textLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.widthAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.widthAnchor, multiplier: 1.0)
        ])
    }
}
