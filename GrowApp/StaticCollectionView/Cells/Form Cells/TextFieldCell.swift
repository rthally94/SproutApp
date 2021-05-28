//
//  TextFieldCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/16/21.
//

import UIKit

private extension UIConfigurationStateCustomKey {
    static let image = UIConfigurationStateCustomKey("net.thally.ryan.TextFieldCell.image")
    static let title = UIConfigurationStateCustomKey("net.thally.ryan.TextFieldCell.title")
    static let placeholder = UIConfigurationStateCustomKey("net.thally.ryan.TextFieldCell.placeholder")
    static let value = UIConfigurationStateCustomKey("net.thally.ryan.TextFieldCell.initalValue")
    static let autocapitalizationType = UIConfigurationStateCustomKey("net.thally.ryan.TextFieldCell.autocapitalizationType")
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

    var autocapitalizationType: UITextAutocapitalizationType {
        set { self[.autocapitalizationType] = value }
        get { return self[.autocapitalizationType] as? UITextAutocapitalizationType ?? .none }
    }
}

class TextFieldCell: UICollectionViewListCell {
    var image: UIImage? {
        didSet {
            if image != oldValue {
                setNeedsUpdateConfiguration()
            }
        }
    }

    var title: String? {
        didSet {
            if title != oldValue {
                setNeedsUpdateConfiguration()
            }
        }
    }

    var placeholder: String? {
        didSet {
            if placeholder != oldValue {
                setNeedsUpdateConfiguration()
            }
        }
    }

    var value: String? {
        didSet {
            if value != oldValue {
                setNeedsUpdateConfiguration()
            }
        }
    }

    var autocapitalizationType: UITextAutocapitalizationType = .none {
        didSet {
            if autocapitalizationType != oldValue {
                setNeedsUpdateConfiguration()
            }
        }
    }

    var onChange: ((String?) -> Void)?

    override var configurationState: UICellConfigurationState {
        var state = super.configurationState
        state.image = image
        state.title = title
        state.placeholder = placeholder
        state.autocapitalizationType = autocapitalizationType
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

        constraints.stackTop.priority-=1
        constraints.stackLeading.priority-=1
        
        NSLayoutConstraint.activate([
            constraints.stackTop,
            constraints.stackLeading,
            constraints.stackBottom,
            constraints.stackTrailing
        ])

        customViewConstraints = constraints

        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
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
        textField.returnKeyType = .done
        textField.autocapitalizationType = state.autocapitalizationType
    }

    private func setupTextField() {
        listContentView.isHidden = configurationState.title == nil

        if configurationState.title != nil {
            textField.textAlignment = effectiveUserInterfaceLayoutDirection == .leftToRight ? .right : .left
        }
    }

    @objc private func textFieldDidChange(_ sender: UITextField) {
        onChange?(textField.text)
    }
}

extension SproutTextFieldCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
