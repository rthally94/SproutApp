//
//  HeaderView.swift
//  Sprout
//
//  Created by Ryan Thally on 6/6/21.
//

import UIKit

class SproutBlurredHeaderView: UIView {
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.setContentHuggingPriority(.defaultHigh+1, for: .vertical)
        return label
    }()

    var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()

    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.alignment = .center
        return stack
    }()

    convenience init() {
        self.init(frame: .zero)
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
        textStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textStack)
        NSLayoutConstraint.activate([
            textStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            textStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            textStack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            textStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        ])
    }

    private func updateViews() {
        titleLabel.isHidden = titleLabel.text == nil
        subtitleLabel.isHidden = subtitleLabel.text == nil

        applyBackgroundBlur()
    }

    private func applyBackgroundBlur() {
        blurBackground(style: .prominent)
    }
}
