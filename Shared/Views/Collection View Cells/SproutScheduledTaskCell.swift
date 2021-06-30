//
//  SproutScheduledTaskCell.swift
//  Sprout
//
//  Created by Ryan Thally on 1/18/21.
//

import UIKit
import SproutKit

private extension UIConfigurationStateCustomKey {
    static let title = UIConfigurationStateCustomKey("net.thally.ryan.SproutListCell.title")
    static let subtitle = UIConfigurationStateCustomKey("net.thally.ryan.SproutListCell.subtitle")
    static let image = UIConfigurationStateCustomKey("net.thally.ryan.SproutListCell.icon")
    static let valueImage = UIConfigurationStateCustomKey("net.thally.ryan.SproutListCell.valueImage")
    static let valueText = UIConfigurationStateCustomKey("net.thally.ryan.SproutListCell.valueText")
}

private extension UICellConfigurationState {
    var title: String? {
        set { self[.title] = newValue }
        get { return self[.title] as? String }
    }

    var subtitle: String? {
        set { self[.subtitle] = newValue }
        get { return self[.subtitle] as? String }
    }

    var valueImage: UIImage? {
        set { self[.valueImage] = newValue }
        get { return self[.valueImage] as? UIImage }
    }

    var valueText: String? {
        set { self[.valueText] = newValue }
        get { return self[.valueText] as? String }
    }

    var image: UIImage? {
        set { self[.image] = newValue }
        get { return self[.image] as? UIImage }
    }
}

class SproutListCell: UICollectionViewListCell {
    var plantName: String? {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }

    var taskType: String? {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }

    var taskScheduleIcon: UIImage? {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }

    var taskScheduleText: String? {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }

    var plantImage: UIImage? {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }
    
    override var configurationState: UICellConfigurationState {
        var state = super.configurationState
        state.title = plantName
        state.subtitle = taskType
        state.valueImage = taskScheduleIcon
        state.valueText = taskScheduleText
        state.image = plantImage
        return state
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        plantImage = nil
        plantName = nil
        taskType = nil
        taskScheduleIcon = nil
        taskScheduleText = nil
        accessories = []
    }
}

class SproutScheduledTaskCell: SproutListCell {
    private let dateFormatter = Utility.dateFormatter
    private let dateComponentsFormatter = Utility.dateComponentsFormatter

    private func defaultListContentConfiguration() -> UIListContentConfiguration {
        var config = UIListContentConfiguration.valueCell()
        config.textProperties.font = UIFont.preferredFont(forTextStyle: .headline)
        config.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .subheadline)
        config.prefersSideBySideTextAndSecondaryText = false
        return config
    }
    private lazy var listContentView = UIListContentView(configuration: defaultListContentConfiguration())
    
    private let plantIconView = SproutIconView()

    private let plantNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.tintColor = .secondaryLabel
        return label
    }()

    private let taskTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.tintColor = .secondaryLabel
        return label
    }()

    private let taskScheduleLabel: SproutLabel = {
        let label = SproutLabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.style = .titleAndIconLabelStyle
        label.tintColor = .secondaryLabel
        return label
    }()

    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [plantNameLabel, taskTypeLabel, UIView.spacer, taskScheduleLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fill
        return stack
    }()

    private var customViewConstraints: (plantIconTop: NSLayoutConstraint, plantIconLeading: NSLayoutConstraint, plantIconWidth: NSLayoutConstraint, plantIconHeight: NSLayoutConstraint)?
    
    private func setupViewsIfNeeded() {
        guard customViewConstraints == nil else { return }
        contentView.addSubview(textStack)
        contentView.addSubview(plantIconView)
        
        textStack.translatesAutoresizingMaskIntoConstraints = false
        plantIconView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = (
            plantIconTop: plantIconView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            plantIconLeading: plantIconView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            plantIconWidth: plantIconView.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor, multiplier: 0.24),
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

            textStack.topAnchor.constraint(equalTo: plantIconView.topAnchor),
            textStack.leadingAnchor.constraint(equalToSystemSpacingAfter: plantIconView.trailingAnchor, multiplier: 2.0),
            textStack.bottomAnchor.constraint(equalTo: plantIconView.bottomAnchor),
            textStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
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
        plantNameLabel.text = state.title
        taskTypeLabel.text = state.subtitle
        taskScheduleLabel.image = state.valueImage
        taskScheduleLabel.text = state.valueText

        var iconConfig = plantIconView.defaultConfiguration()
        iconConfig.image = state.image
//        iconConfig.cornerStyle = .circle
        plantIconView.configuration = iconConfig
        
        content.image = nil
        content.axesPreservingSuperviewLayoutMargins = []
        listContentView.configuration = content

        updateSeparatorConstraint()
    }
}
