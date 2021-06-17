//
//  SproutScheduledTaskCell.swift
//  Sprout
//
//  Created by Ryan Thally on 1/18/21.
//

import UIKit

private extension UIConfigurationStateCustomKey {
    static let text = UIConfigurationStateCustomKey("net.thally.ryan.SproutListCell.text")
    static let secondaryText = UIConfigurationStateCustomKey("net.thally.ryan.SproutListCell.secondaryText")
    static let image = UIConfigurationStateCustomKey("net.thally.ryan.SproutListCell.icon")
    static let daysLate = UIConfigurationStateCustomKey("net.thally.ryan.SproutListCell.daysLate")
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

    var image: UIImage? {
        set { self[.image] = newValue }
        get { return self[.image] as? UIImage }
    }

    var daysLate: Int? {
        set { self[.daysLate] = newValue }
        get { return self[.daysLate] as? Int }
    }
}

class SproutListCell: UICollectionViewListCell {
    private var text: String?
    private var secondaryText: String?
    private var image: UIImage?
    private var daysLate: Int?
    
    func updateWithText(_ text: String?, secondaryText: String?, image: UIImage?, daysLate: Int? = nil) {
        var updated = false
        if self.text != text {
            self.text = text
            updated = true
        }

        if self.secondaryText != secondaryText {
            self.secondaryText = secondaryText
            updated = true
        }

        if self.image != image {
            self.image = image
            updated = true
        }

        if self.daysLate != daysLate {
            self.daysLate = daysLate
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
        state.image = image
        state.daysLate = daysLate
        return state
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        text = nil
        secondaryText = nil
        image = nil
        daysLate = nil
    }
}

class SproutScheduledTaskCell: SproutListCell {
    private let dateFormatter = Utility.dateFormatter
    private let dateComponentsFormatter = Utility.dateComponentsFormatter

    private func defaultListContentConfiguration() -> UIListContentConfiguration { return .subtitleCell() }
    private lazy var listContentView = UIListContentView(configuration: defaultListContentConfiguration())
    
    private lazy var plantIconView = SproutIconView()
    private lazy var taskStatusView = SproutChipView()

    private var customViewConstraints: (plantIconTop: NSLayoutConstraint, plantIconLeading: NSLayoutConstraint, plantIconWidth: NSLayoutConstraint, plantIconHeight: NSLayoutConstraint)?
    
    private func setupViewsIfNeeded() {
        guard customViewConstraints == nil else { return }
        contentView.addSubview(listContentView)
        contentView.addSubview(plantIconView)
        
        listContentView.translatesAutoresizingMaskIntoConstraints = false
        plantIconView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = (
            plantIconTop: plantIconView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            plantIconLeading: plantIconView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            plantIconWidth: plantIconView.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor, multiplier: 0.2),
            plantIconHeight: plantIconView.heightAnchor.constraint(equalTo: plantIconView.widthAnchor)
        )

        constraints.plantIconTop.priority-=1
        constraints.plantIconLeading.priority-=1
        constraints.plantIconHeight.priority-=1
        constraints.plantIconWidth.priority-=1
        
        NSLayoutConstraint.activate([
            constraints.plantIconTop,
            constraints.plantIconLeading,
            constraints.plantIconHeight,
            constraints.plantIconWidth,
            plantIconView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),

            listContentView.topAnchor.constraint(equalTo: plantIconView.topAnchor),
            listContentView.bottomAnchor.constraint(equalTo: plantIconView.bottomAnchor),
            listContentView.leadingAnchor.constraint(equalToSystemSpacingAfter: plantIconView.trailingAnchor, multiplier: 2.0),
            listContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
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
        content.directionalLayoutMargins.leading = 0

        // Configure for just the task
        content.text = state.text
        content.secondaryText = state.secondaryText
            
        var iconConfig = plantIconView.defaultConfiguration()
        iconConfig.image = state.image
        iconConfig.cornerStyle = .circle
        plantIconView.configuration = iconConfig
        
        content.image = nil
        content.axesPreservingSuperviewLayoutMargins = []
        listContentView.configuration = content

        taskStatusView.isHidden = state.daysLate == nil || state.daysLate! <= 0
        if let daysLate = state.daysLate, let dateString = dateComponentsFormatter.string(from: DateComponents(day: daysLate)) {
            taskStatusView.textLabel.text = dateString + " late"
            taskStatusView.backgroundColor = UIColor.systemYellow
        }

        updateSeparatorConstraint()
    }
}
