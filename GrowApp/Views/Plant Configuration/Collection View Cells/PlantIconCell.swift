//
//  ImageCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/17/21.
//

import UIKit

class PlantIconCell: UICollectionViewCell {
    var icon: PlantIcon? {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }

    override func updateConfiguration(using state: UICellConfigurationState) {
        var content = PlantIconContentConfiguration().updated(for: state)

        if let icon = icon {
            switch icon {
                case let .image(image):
                    content.image = image
                    content.presentationMode = .full
                case let .text(text, backgroundColor):
                    content.text = text
                    content.backgroundColor = backgroundColor
                case let .emoji(emoji, backgroundColor):
                    if let emoji = emoji.first {
                        content.text = String(emoji)
                    }
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
    var presentationMode: PlantIconView.PresentationMode = .padded(multiplier: 0.6, points: 0.0)

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
            plantIcon.centerXAnchor.constraint(equalTo: centerXAnchor),
            plantIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            plantIcon.widthAnchor.constraint(equalTo: heightAnchor),
            plantIcon.heightAnchor.constraint(equalTo: heightAnchor)
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
        plantIcon.presentationMode = configuration.presentationMode
    }
}
