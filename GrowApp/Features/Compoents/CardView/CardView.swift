//
//  CardView.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/28/21.
//

import UIKit

class CardView: UIView {
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()

    lazy var secondaryTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return label
    }()

    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [textLabel, secondaryTextLabel])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.alignment = .leading

        stack.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        stack.isLayoutMarginsRelativeArrangement = true

        stack.blurBackground(style: .prominent)

        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }



    private func setupViews() {
        addSubview(imageView)
        addSubview(textStack)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        textStack.translatesAutoresizingMaskIntoConstraints = false

        imageView.pinToBoundsOf(self)
        NSLayoutConstraint.activate([
            textStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            textStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            textStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            textStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            textStack.topAnchor.constraint(greaterThanOrEqualTo: topAnchor)
        ])
    }
}
