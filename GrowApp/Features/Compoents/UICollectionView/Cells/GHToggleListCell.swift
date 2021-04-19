//
//  GHToggleListCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/9/21.
//

import UIKit

private extension UIConfigurationStateCustomKey {
    static let image = UIConfigurationStateCustomKey("net.thally.ryan.GreenHouseToggleListCell.image")
    static let text = UIConfigurationStateCustomKey("net.thally.ryan.GreenHouseToggleListCell.text")
    static let secondaryText = UIConfigurationStateCustomKey("net.thally.ryan.GreenHouseToggleListCell.secondaryText")
    static let isEnabled = UIConfigurationStateCustomKey("net.thally.ryan.GreenHouseToggleListCell.isEnabled")
    static let action = UIConfigurationStateCustomKey("net.thally.ryan.GreenHouseToggleListCell.action")
}

private extension UICellConfigurationState {
    var image: UIImage? {
        set { self[.image] = newValue }
        get { self[.image] as? UIImage }
    }
    
    var text: String? {
        set { self[.text] = newValue }
        get { self[.text] as? String }
    }

    var secondaryText: String? {
        set { self[.secondaryText] = newValue }
        get { self[.secondaryText] as? String }
    }

    var isEnabled: Bool {
        set { self[.isEnabled] = newValue }
        get { self[.isEnabled] as? Bool ?? false }
    }
    
    var action: UIAction? {
        set { self[.action] = newValue }
        get { self[.action] as? UIAction}
    }
}

class GreenHouseToggleCell: UICollectionViewListCell {
    private var image: UIImage?
    private var text: String?
    private var secondaryText: String?
    private var isEnabled: Bool?
    private var action: UIAction?
    
    func updateWith(image newImage: UIImage?, text newText: String?, secondaryText newSecondaryText: String?, isEnabled: Bool?, action newAction: UIAction?) {
        guard image != newImage || text != newText || secondaryText != newSecondaryText, self.isEnabled != isEnabled, action != newAction else { return }
        image = newImage
        text = newText
        secondaryText = newSecondaryText
        self.isEnabled = isEnabled
        action = newAction
        setNeedsUpdateConfiguration()
    }
    
    override var configurationState: UICellConfigurationState {
        var state = super.configurationState
        state.image = image
        state.text = text
        state.secondaryText = secondaryText
        state.isEnabled = isEnabled ?? false
        state.action = action
        return state
    }
}

class ToggleListCell: GreenHouseToggleCell {
    private func defaultListContentConfiguration() -> UIListContentConfiguration { return .subtitleCell() }
    private lazy var listContentView = UIListContentView(configuration: defaultListContentConfiguration())
    
    lazy var toggle = UISwitch(frame: .zero)
    
    private var customViewConstraints: (toggleLeading: NSLayoutConstraint, toggleTrailing: NSLayoutConstraint, toggleCenterY: NSLayoutConstraint)?
    
    private func setupViewsIfNeeded() {
        guard customViewConstraints == nil else { return }
        contentView.addSubview(listContentView)
        contentView.addSubview(toggle)
        
        listContentView.translatesAutoresizingMaskIntoConstraints = false
        toggle.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = (
            toggleLeading: toggle.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: listContentView.trailingAnchor, multiplier: 1.0),
            toggleTrailing: toggle.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            toggleCenterY: toggle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        )
        
        NSLayoutConstraint.activate([
            listContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            listContentView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            listContentView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            
            constraints.toggleLeading,
            constraints.toggleTrailing,
            constraints.toggleCenterY
        ])
        
        customViewConstraints = constraints
    }
    
    private var separatorConstraint: NSLayoutConstraint?
    private func updateSeparatorConstraint() {
        guard let textLayoutGuide = listContentView.textLayoutGuide else { return }
        if let existingConstraint = separatorConstraint, existingConstraint.isActive {
            return
        }
        
        let constraint = separatorLayoutGuide.leadingAnchor.constraint(equalTo: textLayoutGuide.leadingAnchor)
        constraint.isActive = true
        separatorConstraint = constraint
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        setupViewsIfNeeded()
        
        var content = defaultListContentConfiguration().updated(for: state)
        content.image = state.image
        content.text = state.text
        content.secondaryText = state.secondaryText
        
        toggle.isOn = state.isEnabled
        if let action = state.action {
            toggle.addAction(action, for: .valueChanged)
        }
        
        listContentView.configuration = content
        updateSeparatorConstraint()
    }
}
