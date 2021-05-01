//
//  ButtonCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/18/21.
//

import UIKit

class ButtonCell: UICollectionViewCell {
    static let buttonFont = UIFont.preferredFont(forTextStyle: .headline)
    enum DisplayMode: Int {
        case normal, primary, destructive
    }

    var image: UIImage? {
        set { imageView.image = newValue }
        get { imageView.image }
    }

    var text: String? {
        set { textLabel.text = newValue }
        get { textLabel.text }
    }

    var displayContext: DisplayMode = .normal {
        didSet {
            applyButtonStyling()
        }
    }

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.preferredSymbolConfiguration = .init(font: ButtonCell.buttonFont)

        let HCHP = view.contentHuggingPriority(for: .horizontal)
        let VCHP = view.contentHuggingPriority(for: .vertical)

        view.setContentHuggingPriority(HCHP+1, for: .horizontal)
        view.setContentHuggingPriority(VCHP+1, for: .vertical)
        return view
    }()

    private lazy var textLabel: UILabel = {
        let view = UILabel()
        view.font = ButtonCell.buttonFont
        return view
    }()

    private lazy var stack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [imageView, textLabel])
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fill
        view.spacing = 4
        return view
    }()

    private var appliedConstraints: (stackTop: NSLayoutConstraint, stackBottom: NSLayoutConstraint, stackCenterX: NSLayoutConstraint, stackWidth: NSLayoutConstraint)?

    override func layoutSubviews() {
        super.layoutSubviews()

        setupViewsIfNeeded()
    }

    private func setupViewsIfNeeded() {
        guard appliedConstraints == nil else { return }

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        let constraints = (
            stackTop: stack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            stackBottom: stack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            stackCenterX: stack.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            stackWidth: stack.widthAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.widthAnchor)
        )

        constraints.stackWidth.priority-=1

        NSLayoutConstraint.activate([
            constraints.stackTop,
            constraints.stackBottom,
            constraints.stackCenterX,
            constraints.stackWidth
        ])

        appliedConstraints = constraints

        imageView.isHidden = imageView.image == nil
        textLabel.isHidden = textLabel.text == nil

        applyButtonStyling()
    }

    private func applyButtonStyling() {
        switch displayContext {
        case .normal:
            contentView.backgroundColor = .secondarySystemGroupedBackground
            imageView.tintColor = tintColor
            textLabel.textColor = tintColor
        case .primary:
            contentView.backgroundColor = tintColor
            let labelColor = UIColor.labelColor(against: tintColor)
            imageView.tintColor = labelColor
            textLabel.textColor = labelColor
        case .destructive:
            contentView.backgroundColor = .secondarySystemGroupedBackground
            imageView.tintColor = .systemRed
            textLabel.textColor = .systemRed
        }
    }
}
