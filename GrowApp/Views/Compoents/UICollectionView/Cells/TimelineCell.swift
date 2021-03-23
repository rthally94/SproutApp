//
//  TimelineCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/18/21.
//

import UIKit

fileprivate extension UIConfigurationStateCustomKey {
    static let plant = UIConfigurationStateCustomKey("net.thally.ryan.GreenHouseListCell.plant")
    static let task = UIConfigurationStateCustomKey("net.thally.ryan.GreenHouseListCell.task")
}

private extension UICellConfigurationState {
    var plant: Plant? {
        set { self[.plant] = newValue }
        get { return self[.plant] as? Plant }
    }
    
    var task: Task? {
        set { self[.task] = newValue }
        get { return self[.task] as? Task }
    }
}

class GreenHouseListCell: UICollectionViewListCell {
    private var plant: Plant? = nil
    private var task: Task? = nil
    
    func updateWith(task newTask: Task, plant newPlant: Plant) {
        updateWithTask(newTask)
        updateWithPlant(newPlant)
    }
    
    func updateWithTask(_ newTask: Task) {
        guard task != newTask else { return }
        task = newTask
        setNeedsUpdateConfiguration()
    }
    
    func updateWithPlant(_ newPlant: Plant) {
        guard plant != newPlant else { return }
        plant = newPlant
        setNeedsUpdateConfiguration()
    }
    
    override var configurationState: UICellConfigurationState {
        var state = super.configurationState
        state.plant = self.plant
        return state
    }
}

class TimelinePlantListCell: GreenHouseListCell {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        
        return formatter
    }()
    
    private func defaultListContentConfiguration() -> UIListContentConfiguration { return .subtitleCell() }
    private lazy var listContentView = UIListContentView(configuration: defaultListContentConfiguration())
    
    private lazy var plantIconView = IconView()
    private var customViewConstraints: (plantIconLeading: NSLayoutConstraint, plantIconWidth: NSLayoutConstraint, plantIconTop: NSLayoutConstraint)?
    
    private func setupViewsIfNeeded() {
        guard customViewConstraints == nil else { return }
        plantIconView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(listContentView)
        contentView.addSubview(plantIconView)
        listContentView.translatesAutoresizingMaskIntoConstraints = false
        plantIconView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = (
            plantIconLeading: plantIconView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            plantIconWidth: plantIconView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.125),
            plantIconTop: plantIconView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor)
        )
        constraints.plantIconTop.priority-=1
        
        NSLayoutConstraint.activate([
            constraints.plantIconLeading,
            constraints.plantIconWidth,
            plantIconView.heightAnchor.constraint(equalTo: plantIconView.widthAnchor),
            constraints.plantIconTop,
            plantIconView.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            
            listContentView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            listContentView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            listContentView.leadingAnchor.constraint(equalToSystemSpacingAfter: plantIconView.trailingAnchor, multiplier: 1.0),
            listContentView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
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
        
        if let plant = state.plant, let task = state.task {
            // Configure for both present
            content.text = plant.name.capitalized
            if let lastCareDate = task.lastCareDate {
                content.secondaryText = "Last: " + TimelinePlantListCell.dateFormatter.string(from: lastCareDate)
            } else {
                content.secondaryText = "Last: Never"
            }
            plantIconView.iconViewConfiguration = .init(icon: plant.icon, cornerMode: .circle)
            
        } else if let plant = state.plant {
            // Configure for just the plant
            content.text = plant.name.capitalized
            content.secondaryText = "\(plant.tasks.count) tasks"
            plantIconView.iconViewConfiguration = .init(icon: plant.icon, cornerMode: .circle)
        } else if let task = state.task {
            // Configure for just the task
            content.text = task.type.description
            if let lastCareDate = task.lastCareDate {
                content.secondaryText = "Last: " + TimelinePlantListCell.dateFormatter.string(from: lastCareDate)
            } else {
                content.secondaryText = "Last: Never"
            }
            plantIconView.iconViewConfiguration = .init(icon: task.type.icon, cornerMode: CornerStyle.none)
        }
        
        content.image = nil
        content.axesPreservingSuperviewLayoutMargins = []
        listContentView.configuration = content
        
        customViewConstraints?.plantIconLeading.constant = content.directionalLayoutMargins.trailing
        customViewConstraints?.plantIconTop.constant = content.directionalLayoutMargins.top
        updateSeparatorConstraint()
    }
}
