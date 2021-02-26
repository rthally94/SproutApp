//
//  TimelineCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/18/21.
//

import UIKit

class TimelineCell: UICollectionViewListCell {
    static let reuseIdentifier = "TimelineCellReuseIdentifier"

    lazy var plantIconView: PlantIconView = {
        let piv = PlantIconView()
        piv.iconMode = .circle
        let priority = piv.contentHuggingPriority(for: .horizontal) + 1
        piv.setContentHuggingPriority(priority, for: .horizontal)
        return piv
    }()

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
        textStack.distribution = .fillEqually
        return textStack
    }()

    let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .headline)
    lazy var incompleteSymbol = UIImage(systemName: "circle", withConfiguration: symbolConfiguration)
    lazy var completeSymbol = UIImage(systemName: "checkmark.circle.fill", withConfiguration: symbolConfiguration)

    lazy var todoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(incompleteSymbol, for: .normal)

        let priority = btn.contentHuggingPriority(for: .horizontal) + 1
        btn.setContentHuggingPriority(priority, for: .horizontal)
        return btn
    }()

    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        configureHiearchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureHiearchy() {
        plantIconView.translatesAutoresizingMaskIntoConstraints = false
        textStack.translatesAutoresizingMaskIntoConstraints = false
        todoButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(plantIconView)
        contentView.addSubview(textStack)
        contentView.addSubview(todoButton)
        
        NSLayoutConstraint.activate([
            plantIconView.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            plantIconView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            plantIconView.heightAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.heightAnchor),
            plantIconView.widthAnchor.constraint(equalTo: plantIconView.heightAnchor),

            textStack.leadingAnchor.constraint(equalToSystemSpacingAfter: plantIconView.trailingAnchor, multiplier: 1.0),
            textStack.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            textStack.heightAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.heightAnchor),

            separatorLayoutGuide.leadingAnchor.constraint(equalTo: textStack.leadingAnchor),

            todoButton.leadingAnchor.constraint(equalToSystemSpacingAfter: textStack.trailingAnchor, multiplier: 1.0),
            todoButton.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            todoButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            todoButton.heightAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.heightAnchor)
        ])
    }
}
