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
    private let upNextView = SproutUpNextView()

    private var needsLayout = true
    private func setupViewIfNeeded() {
        guard needsLayout else { return }

        contentView.addSubview(upNextView)
        upNextView.translatesAutoresizingMaskIntoConstraints = false

        let top = upNextView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor)
        let leading = upNextView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor)
        let bottom = upNextView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        let trailing = upNextView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)

        top.priority -= 1
        leading.priority -= 1
        
        NSLayoutConstraint.activate([
            top,
            leading,
            bottom,
            trailing
        ])


        needsLayout = false
    }

    private var separatorConstraint: NSLayoutConstraint?
    private func updateSeparatorConstraint() {
        guard let textLayoutGuide = upNextView.textLayoutGuide else { return }
        if let existingConstraint = separatorConstraint, existingConstraint.isActive {
            return
        }
        
        let constraint = separatorLayoutGuide.leadingAnchor.constraint(equalTo: textLayoutGuide.leadingAnchor)
        constraint.isActive = true
        separatorConstraint = constraint
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        setupViewIfNeeded()

        // Configure for just the task
        upNextView.plantNameLabel.text = state.title

        let subtitleString: String?
        switch(state.subtitle, state.valueText) {
        case let (subtitle?, value?):
            subtitleString = subtitle + " • " + value
        case let (subtitle?, _):
            subtitleString = subtitle
        case let (_, value?):
            subtitleString = value
        default:
            subtitleString = nil
        }

        upNextView.taskTypeLabel.text = subtitleString

        var iconConfig = upNextView.plantIconView.defaultConfiguration()
        iconConfig.image = state.image
        upNextView.plantIconView.configuration = iconConfig

        updateSeparatorConstraint()
    }
}
