//
//  TimelineCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/18/21.
//

import UIKit

class TimelineCell: UICollectionViewListCell {
    func timelineConfiguration() -> TimelineCellContentConfiguration {
        TimelineCellContentConfiguration(plantIcon: .symbol(name: "exclamation", foregroundColor: nil, backgroundColor: .systemGray), plantName: "Plant Name", plantDetail: "Plant Detail", isComplete: false)
    }
}

struct TimelineCellContentConfiguration: UIContentConfiguration, Hashable {
    var plantIcon: Icon
    var plantName: String
    var plantDetail: String
    var isComplete: Bool
    
    func makeContentView() -> UIView & UIContentView {
        return TimelineCellContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> TimelineCellContentConfiguration {
        return self
    }
}

class TimelineCellContentView: UIView & UIContentView {
    init(configuration: TimelineCellContentConfiguration) {
        super.init(frame: .zero)
        
        setupInternalViews()
        apply(configuration: configuration)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var plantIconView = IconView()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        return titleLabel
    }()
    
    lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return subtitleLabel
    }()
    
    lazy var textStack: UIStackView = {
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.alignment = .leading
        textStack.axis = .vertical
        textStack.distribution = .fill
        return textStack
    }()
    
    let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .headline)
    lazy var incompleteSymbol = UIImage(systemName: "circle", withConfiguration: symbolConfiguration)
    lazy var completeSymbol = UIImage(systemName: "checkmark.circle.fill", withConfiguration: symbolConfiguration)
    
    lazy var todoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(incompleteSymbol, for: .normal)
        return btn
    }()
    
    func setupInternalViews() {
        plantIconView.translatesAutoresizingMaskIntoConstraints = false
        textStack.translatesAutoresizingMaskIntoConstraints = false
        todoButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(plantIconView)
        addSubview(textStack)
        addSubview(todoButton)
        
        let constraints = (
            plantIconTop: plantIconView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            plantIconLeading: plantIconView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            plantIconHeight: plantIconView.heightAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.heightAnchor),
            textStackTop: textStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            todoButtonHeight: todoButton.heightAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.heightAnchor)
        )
        
        constraints.plantIconTop.priority = .required - 1
        constraints.plantIconLeading.priority = .required - 1
        constraints.plantIconHeight.priority = .required - 1
        constraints.textStackTop.priority = .required - 1
        constraints.todoButtonHeight.priority = .required - 1
        
        NSLayoutConstraint.activate([
            constraints.plantIconTop,
            constraints.plantIconLeading,
            plantIconView.heightAnchor.constraint(equalToConstant: 60),
            plantIconView.widthAnchor.constraint(equalToConstant: 60),
            constraints.plantIconHeight,
            
            textStack.leadingAnchor.constraint(equalToSystemSpacingAfter: plantIconView.trailingAnchor, multiplier: 2.0),
            constraints.textStackTop,
            textStack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            
            todoButton.centerYAnchor.constraint(equalTo: layoutMarginsGuide.centerYAnchor),
            constraints.todoButtonHeight,
            todoButton.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: textStack.trailingAnchor, multiplier: 2.0),
            todoButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
        ])
    }
    
    var configuration: UIContentConfiguration {
        get { appliedConfiguration }
        set {
            guard let newConfig = newValue as? TimelineCellContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }
    
    private var appliedConfiguration: TimelineCellContentConfiguration!
    private func apply(configuration: TimelineCellContentConfiguration) {
        guard appliedConfiguration != configuration else { return }
        appliedConfiguration = configuration
        
        // Configure Views
        var config = plantIconView.defaultConfiguration()
        config.icon = configuration.plantIcon
        plantIconView.iconViewConfiguration = config
        
        titleLabel.text = appliedConfiguration.plantName
        subtitleLabel.text = appliedConfiguration.plantDetail
        
        let image = appliedConfiguration.isComplete ? completeSymbol : incompleteSymbol
        todoButton.setImage(image, for: .normal)
    }
}
