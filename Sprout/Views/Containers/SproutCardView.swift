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
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    let secondaryTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return label
    }()

    private lazy var textStack: UIStackView = { [unowned self] in
        let stack = UIStackView(arrangedSubviews: [textLabel, secondaryTextLabel])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .leading

        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
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

        let textStackTrailing = textStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        textStackTrailing.priority-=1
        let textStackMinHeight = textStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        textStackMinHeight.priority-=1
        let textStackTop = textStack.topAnchor.constraint(greaterThanOrEqualTo: topAnchor)
        textStackTop.priority-=1


        imageView.pinToBoundsOf(self)
        NSLayoutConstraint.activate([
            textStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            textStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            textStackTrailing,
            textStackMinHeight,
            textStackTop
        ])
    }
}
