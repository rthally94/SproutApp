//
//  TimelineCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/18/21.
//

import UIKit

private extension UIConfigurationStateCustomKey {
    static let text = UIConfigurationStateCustomKey("net.thally.ryan.GreenHouseListCell.text")
    static let secondaryText = UIConfigurationStateCustomKey("net.thally.ryan.GreenHouseListCell.secondaryText")
    static let icon = UIConfigurationStateCustomKey("net.thally.ryan.GreenHouseListCell.icon")
}

private extension UICellConfigurationState {
    var text: String? {
        set { self[.text] = newValue }
        get { return self[.text] as? String }
    }

    var secondaryText: String? {
        set { self[.secondaryText] = newValue }
        get { return self[.secondaryText] as? String }
    }

    var icon: GHIcon? {
        set { self[.icon] = newValue }
        get { return self[.icon] as? GHIcon }
    }
}

class GreenHouseListCell: UICollectionViewListCell {
    private var text: String?
    private var secondaryText: String?
    private var icon: GHIcon?
    
    func updateWithText(_ text: String?, secondaryText: String?, icon: GHIcon?) {
        var updated = false
        if self.text != text {
            self.text = text
            updated = true
        }

        if self.secondaryText != secondaryText {
            self.secondaryText = secondaryText
            updated = true
        }

        if self.icon != icon {
            self.icon = icon
            updated = true
        }

        if updated {
            setNeedsUpdateConfiguration()
        }
    }
    
    override var configurationState: UICellConfigurationState {
        var state = super.configurationState
        state.text = text
        state.secondaryText = secondaryText
        state.icon = icon
        return state
    }
}

class TaskCalendarListCell: GreenHouseListCell {
    private let dateFormatter = Utility.dateFormatter
    private func defaultListContentConfiguration() -> UIListContentConfiguration { return .subtitleCell() }
    private lazy var listContentView = UIListContentView(configuration: defaultListContentConfiguration())
    
    private lazy var plantIconView = IconView()
    
    private var customViewConstraints: (plantIconLeading: NSLayoutConstraint, plantIconWidth: NSLayoutConstraint, plantIconHeight: NSLayoutConstraint, listContentTop: NSLayoutConstraint)?
    
    private func setupViewsIfNeeded() {
        guard customViewConstraints == nil else { return }
        contentView.addSubview(listContentView)
        contentView.addSubview(plantIconView)
        
        listContentView.translatesAutoresizingMaskIntoConstraints = false
        plantIconView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = (
            plantIconLeading: plantIconView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            plantIconWidth: plantIconView.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor, multiplier: 0.15),
            plantIconHeight: plantIconView.heightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.heightAnchor),
            listContentTop: listContentView.topAnchor.constraint(equalTo: plantIconView.topAnchor)
        )
        
        constraints.plantIconLeading.priority-=1
        constraints.plantIconHeight.priority-=1
        constraints.plantIconWidth.priority-=1
        constraints.listContentTop.priority-=1
        
        NSLayoutConstraint.activate([
            constraints.plantIconLeading,
            constraints.plantIconHeight,
            constraints.plantIconWidth,
            plantIconView.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            
            constraints.listContentTop,
            listContentView.bottomAnchor.constraint(equalTo: plantIconView.bottomAnchor),
            listContentView.leadingAnchor.constraint(equalTo: plantIconView.trailingAnchor),
            listContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
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

        // Configure for just the task
        content.text = state.text
        content.secondaryText = state.secondaryText
            
        var iconConfig = plantIconView.defaultConfiguration()
        iconConfig.image = state.icon?.image
        iconConfig.tintColor = state.icon?.color
        iconConfig.cornerStyle = .circle
        plantIconView.configuration = iconConfig
        
        content.image = nil
        content.axesPreservingSuperviewLayoutMargins = []
        listContentView.configuration = content
        
        updateSeparatorConstraint()
    }
}
