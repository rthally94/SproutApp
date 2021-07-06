//
//  SproutUpNextView.swift
//  Sprout
//
//  Created by Ryan Thally on 7/2/21.
//

import UIKit

class SproutUpNextView: UIView {
    let plantIconView = SproutIconView()
    let plantNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.allowsDefaultTighteningForTruncation = true
        label.numberOfLines = 2
        return label
    }()

    let taskTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }()

    let taskScheduleLabel: SproutLabel = {
        let label = SproutLabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.style = .titleAndIconLabelStyle
        label.tintColor = .secondaryLabel
        return label
    }()

    private lazy var containerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [plantIconView, textStack])
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 12
        return stack
    }()

    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [plantNameLabel, UIView.spacer, taskTypeLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fill
        return stack
    }()

    var textLayoutGuide: UILayoutGuide? {
        return textStack.layoutMarginsGuide
    }

    private var customViewConstraints: (top: NSLayoutConstraint, leading: NSLayoutConstraint, bottom: NSLayoutConstraint, trailing: NSLayoutConstraint)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViewsIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViewsIfNeeded() {
        guard customViewConstraints == nil else { return }

        addSubview(containerStack)
        containerStack.translatesAutoresizingMaskIntoConstraints = false

        let constraints = (
            top: containerStack.topAnchor.constraint(equalTo: topAnchor),
            leading: containerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottom: containerStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            trailing: containerStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        )

        plantIconView.translatesAutoresizingMaskIntoConstraints = false
        let plantIconWidth = plantIconView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2)
        plantIconWidth.priority-=1
        plantIconWidth.isActive = true

        NSLayoutConstraint.activate([
            constraints.top,
            constraints.leading,
            constraints.bottom,
            constraints.trailing
        ])

        customViewConstraints = constraints
    }
}
