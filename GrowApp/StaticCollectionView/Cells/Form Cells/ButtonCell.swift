//
//  ButtonCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/18/21.
//

import UIKit

private extension UIConfigurationStateCustomKey {
    static let image = UIConfigurationStateCustomKey("net.thally.ryan.SproutButtonCell.image")
    static let title = UIConfigurationStateCustomKey("net.thally.ryan.SproutButtonCell.title")
    static let displayMode = UIConfigurationStateCustomKey("net.thally.ryan.SproutButtonCell.displayMode")
}

private extension UICellConfigurationState {
    typealias DisplayModeType = ButtonCell.DisplayMode

    var image: UIImage? {
        set { self[.image] = newValue }
        get { return self[.image] as? UIImage }
    }

    var title: String? {
        set { self[.title] = newValue }
        get { return self[.title] as? String }
    }

    var displayMode: DisplayModeType {
        set { self[.displayMode] = newValue }
        get { return self[.displayMode] as? DisplayModeType ?? .normal }
    }
}

class ButtonCell: UICollectionViewCell {
    enum DisplayMode: Int {
        case plain, normal, primary, destructive
    }

    var image: UIImage? { didSet {
        if image != oldValue {
            setNeedsUpdateConfiguration()
        }
    }}

    var title: String? { didSet {
        if title != oldValue {
            setNeedsUpdateConfiguration()
        }
    }}

    var displayMode: DisplayMode = .normal { didSet {
        if displayMode != oldValue {
            setNeedsUpdateConfiguration()
        }
    }}

    override var isSelected: Bool { didSet {
        if isSelected != oldValue {
            setNeedsUpdateConfiguration()
        }
    }}

    override var configurationState: UICellConfigurationState {
        var state = super.configurationState
        state.image = image
        state.title = title
        state.displayMode = displayMode
        state.isSelected = isSelected
        return state
    }
}

class SproutButtonCell: ButtonCell {
    static let buttonFont = UIFont.preferredFont(forTextStyle: .headline)

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.preferredSymbolConfiguration = .init(font: SproutButtonCell.buttonFont)

        let HCHP = view.contentHuggingPriority(for: .horizontal)
        let VCHP = view.contentHuggingPriority(for: .vertical)

        view.setContentHuggingPriority(HCHP+2, for: .horizontal)
        view.setContentHuggingPriority(VCHP+2, for: .vertical)
        return view
    }()

    private lazy var textLabel: UILabel = {
        let view = UILabel()
        view.font = SproutButtonCell.buttonFont
        return view
    }()

    private lazy var stack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [imageView, textLabel])
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = 8.0
        return view
    }()

    private var appliedConstraints: (stackTop: NSLayoutConstraint, stackBottom: NSLayoutConstraint, stackCenterX: NSLayoutConstraint, stackWidth: NSLayoutConstraint)?

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

        constraints.stackTop.priority-=1
        constraints.stackWidth.priority-=1

        NSLayoutConstraint.activate([
            constraints.stackTop,
            constraints.stackBottom,
            constraints.stackCenterX,
            constraints.stackWidth
        ])

        appliedConstraints = constraints
    }

    override func updateConfiguration(using state: UICellConfigurationState) {
        setupViewsIfNeeded()

        // Apply configuration properties
        imageView.image = state.image
        imageView.isHidden = state.image == nil

        textLabel.text = state.title
        textLabel.isHidden = state.title == nil

        // Style based on selection context
        if state.isSelected {
            // Apply selection styling
            applySelectedButtonStyle(forMode: state.displayMode)
        } else if state.isDisabled {
            // Apply disabled styling
            applyDisabledButtonStyle(forMode: state.displayMode)
        } else {
            // Apply default styling
            applyDefaultButtonStyle(forMode: state.displayMode)
        }

    }
}

private extension SproutButtonCell {
    func applyDefaultButtonStyle(forMode mode: DisplayMode) {
        switch mode {
        case .plain:
            contentView.backgroundColor = .clear
            imageView.tintColor = tintColor
            textLabel.textColor = tintColor
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

    func applySelectedButtonStyle(forMode mode: DisplayMode) {
        switch mode {
        case .plain:
            let bgColor = tintColor
            contentView.backgroundColor = bgColor
            imageView.tintColor = UIColor.labelColor(against: bgColor)
            textLabel.textColor = UIColor.labelColor(against: bgColor)
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

    func applyDisabledButtonStyle(forMode mode: DisplayMode) {
        switch mode {
        case .plain:
            contentView.backgroundColor = .clear
            imageView.tintColor = UIColor.systemGray
            textLabel.textColor = UIColor.systemGray
        case .normal, .primary:
            contentView.backgroundColor = .systemFill
            imageView.tintColor = .systemGray
            textLabel.textColor = .systemGray
        case .destructive:
            contentView.backgroundColor = .systemFill
            imageView.tintColor = UIColor.systemRed.withAlphaComponent(0.5)
            textLabel.textColor = UIColor.systemRed.withAlphaComponent(0.5)
        }
    }
}
