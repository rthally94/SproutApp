//
//  TimelineCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/18/21.
//

import UIKit

private extension UIConfigurationStateCustomKey {
    static let task = UIConfigurationStateCustomKey("net.thally.ryan.GreenHouseListCell.task")
}

private extension UICellConfigurationState {
    var task: GHTask? {
        set { self[.task] = newValue }
        get { return self[.task] as? GHTask }
    }
}

class GreenHouseListCell: UICollectionViewListCell {
    private var task: GHTask?
    
    func updateWithTask(_ newTask: GHTask) {
        guard task != newTask else { return }
        task = newTask
        setNeedsUpdateConfiguration()
    }
    
    override var configurationState: UICellConfigurationState {
        var state = super.configurationState
        state.task = task
        return state
    }
}

class TaskCalendarListCell: GreenHouseListCell {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        
        return formatter
    }()
    
    private func defaultListContentConfiguration() -> UIListContentConfiguration { return .subtitleCell() }
    private lazy var listContentView = UIListContentView(configuration: defaultListContentConfiguration())
    
    private lazy var plantIconView = IconView()
    
    private var customViewConstraints: (plantIconLeading: NSLayoutConstraint, plantIconWidth: NSLayoutConstraint, plantIconHeight: NSLayoutConstraint, listContentTop: NSLayoutConstraint)?
    
    private func setupViewsIfNeeded() {
        guard customViewConstraints == nil else { return }
        plantIconView.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        if let task = state.task {
            // Configure for just the task
            content.text = task.category?.name
            if let lastLogDate = task.lastLogDate {
                content.secondaryText = "Last: " + TaskCalendarListCell.dateFormatter.string(from: lastLogDate)
            } else {
                content.secondaryText = "Last: Never"
            }
            
            var iconConfig = plantIconView.defaultConfiguration()
            iconConfig.image = task.category?.icon?.image
            iconConfig.tintColor = task.category?.icon?.color
            iconConfig.cornerStyle = .none
            plantIconView.iconViewConfiguration = iconConfig
        }
        
        content.image = nil
        content.axesPreservingSuperviewLayoutMargins = []
        listContentView.configuration = content
        
        updateSeparatorConstraint()
    }
}
