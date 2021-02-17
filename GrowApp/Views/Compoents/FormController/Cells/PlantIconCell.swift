//
//  ImageCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/17/21.
//

import UIKit

class PlantIconCell: UICollectionViewCell {
    var icon: PlantIcon?

    override func updateConfiguration(using state: UICellConfigurationState) {
        var content = PlantIconContentConfiguration().updated(for: state)

        if let icon = icon {
            switch icon {
                case let .image(image):
                    content.image = image
                case let .text(emoji, backgroundColor):
                    content.text = emoji
                    content.backgroundColor = backgroundColor
                case let .symbol(name, backgroundColor):
                    content.image = UIImage(systemName: name)
                    content.backgroundColor = backgroundColor
            }
        }

        contentConfiguration = content
    }
}

struct PlantIconContentConfiguration: UIContentConfiguration, Hashable {
    var text: String? = nil
    var image: UIImage? = nil
    var backgroundColor: UIColor? = nil

    func makeContentView() -> UIView & UIContentView {
        return PlantIconContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> PlantIconContentConfiguration {
        return self
    }
}

class PlantIconContentView: UIView & UIContentView {
    init(configuration: PlantIconContentConfiguration) {
        super.init(frame: .zero)

        self.configuration = configuration
        setupInternalViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var configuration: UIContentConfiguration {
        get { appliedContentConfiguration }
        set {
            guard let newConfig = newValue as? PlantIconContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }

    private let plantIcon = PlantIconView()

    func setupInternalViews() {
        addSubview(plantIcon)
        plantIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            plantIcon.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            plantIcon.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            plantIcon.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
            plantIcon.widthAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.widthAnchor, multiplier: 1.0)
        ])
    }

    private var appliedContentConfiguration: PlantIconContentConfiguration!
    private func apply(configuration: PlantIconContentConfiguration) {
        guard appliedContentConfiguration != configuration else { return }
        appliedContentConfiguration = configuration

        // configure view
        plantIcon.image = configuration.image
        plantIcon.text = configuration.text
        plantIcon.backgroundColor = configuration.backgroundColor
    }
}
