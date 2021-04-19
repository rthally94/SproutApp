//
//  TextFieldCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/16/21.
//

import UIKit

private extension UIConfigurationStateCustomKey {
    static let image = UIConfigurationStateCustomKey("net.thally.ryan.GreenHouseTextFieldCell.image")
    static let title = UIConfigurationStateCustomKey("net.thally.ryan.GreenHouseTextFieldCell.title")
    static let placeholder = UIConfigurationStateCustomKey("net.thally.ryan.GreenHouseTextFieldCell.placeholder")
    static let value = UIConfigurationStateCustomKey("net.thally.ryan.GreenHouseTextFieldCell.initalValue")
}

private extension UICellConfigurationState {
    var image: UIImage? {
        set { self[.image] = newValue }
        get { return self[.image] as? UIImage }
    }

    var title: String? {
        set { self[.title] = newValue }
        get { return self[.title] as? String }
    }

    var placeholder: String? {
        set { self[.placeholder] = newValue }
        get { return self[.placeholder] as? String}
    }

    var value: String? {
        set { self[.value] = newValue }
        get { return self[.value] as? String }
    }
}

class TextFieldCell: UICollectionViewListCell {
    private var image: UIImage?
    private var title: String?
    private var placeholder: String?
    private var value: String?

    func updateWith(image: UIImage?, title: String?, placeholder: String?, value: String?) {
        var updated = false

        if self.image != image {
            self.image = image
            updated = true
        }

        if self.title != title {
            self.title = title
            updated = true
        }

        if self.placeholder != placeholder {
            self.placeholder = placeholder
            updated = true
        }

        if self.value != value {
            self.value = value
            updated = true
        }

        if updated {
            setNeedsUpdateConfiguration()
        }
    }

    override var configurationState: UICellConfigurationState {
        var state = super.configurationState
        state.image = image
        state.title = title
        state.placeholder = placeholder
        state.value = value
        return state
    }
}

class SproutTextFieldCell: TextFieldCell {
    private func defaultListContentConfiguration() -> UIListContentConfiguration { return .cell() }
    private lazy var listContentView = UIListContentView(configuration: defaultListContentConfiguration())
    private let textField = UITextField()
    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [listContentView, textField])
        stack.alignment = .center
        stack.axis = .horizontal
        stack.distribution = .fill
        return stack
    }()

//    private var customViewConstraints: (textFieldLeading: NSLayoutConstraint, textFieldCenterY: NSLayoutConstraint, textFieldTrailing: NSLayoutConstraint)?
    private var customViewConstraints: (
        stackTop: NSLayoutConstraint, stackLeading: NSLayoutConstraint, stackBottom: NSLayoutConstraint, stackTrailing: NSLayoutConstraint)?

    private func setupViewsIfNeeded() {
        guard customViewConstraints == nil else { return }
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        let constraints = (
            stackTop: stack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: 2),
            stackLeading: stack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stackBottom: stack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor, constant: -2),
            stackTrailing: stack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        )

        NSLayoutConstraint.activate([
            constraints.stackTop,
            constraints.stackLeading,
            constraints.stackBottom,
            constraints.stackTrailing
        ])

        customViewConstraints = constraints

        textField.delegate = self
        setupTextField()
    }

    override func updateConfiguration(using state: UICellConfigurationState) {
        setupViewsIfNeeded()

        var contentConfig = defaultListContentConfiguration().updated(for: state)
        contentConfig.text = state.title
        contentConfig.secondaryText = nil
        contentConfig.image = state.image
        listContentView.configuration = contentConfig

        textField.placeholder = state.placeholder
        textField.text = state.value
    }

    private func setupTextField() {
        listContentView.isHidden = configurationState.title == nil

        if configurationState.title != nil {
            textField.textAlignment = effectiveUserInterfaceLayoutDirection == .leftToRight ? .right : .left
        }
    }
}

extension SproutTextFieldCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
//        appliedConfiguration.onChange?(textField)
    }
}
