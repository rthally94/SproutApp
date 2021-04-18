//
//  TextFieldCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/16/21.
//

import UIKit

class TextFieldCell: UICollectionViewListCell {
    func defaultTextFieldConfiguration() -> TextFieldContentConfiguration {
        var config = TextFieldContentConfiguration()
        config.placeholder = "Enter Text"
        config.value = ""
        config.autocapitalizationType = .none
        return config
    }
}

struct TextFieldContentConfiguration: UIContentConfiguration, Hashable {
    var value: String? = nil
    var placeholder: String? = nil
    var autocapitalizationType: UITextAutocapitalizationType = .none
    var onChange: ((String) -> Void)?

    func makeContentView() -> UIView & UIContentView {
        return TextFieldContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> TextFieldContentConfiguration {
        return self
    }
    
    static func == (lhs: TextFieldContentConfiguration, rhs: TextFieldContentConfiguration) -> Bool {
        return lhs.value == rhs.value
            && lhs.placeholder == rhs.placeholder
            && lhs.autocapitalizationType == rhs.autocapitalizationType
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
        hasher.combine(placeholder)
        hasher.combine(autocapitalizationType)
    }
}

class TextFieldContentView: UIView & UIContentView {
    // MARK: - Initializers
    init(configuration: TextFieldContentConfiguration) {
        super.init(frame: .zero)
        setupInternalViews()
        apply(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var configuration: UIContentConfiguration {
        get { appliedConfiguration }
        set {
            guard let newConfig = newValue as? TextFieldContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }

    private let textField = UITextField()

    private func setupInternalViews() {
        textField.delegate = self
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -12),
            textField.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 2),
            textField.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -2)
        ])
    }

    private var appliedConfiguration: TextFieldContentConfiguration!
    private func apply(configuration: TextFieldContentConfiguration) {
        guard appliedConfiguration != configuration else { return }
        appliedConfiguration = configuration

        // configure view
        textField.placeholder = configuration.placeholder
        textField.text = configuration.value
        textField.autocapitalizationType = configuration.autocapitalizationType
    }
}

extension TextFieldContentView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            appliedConfiguration.onChange?(text)
        }
    }
}
