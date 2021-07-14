//
//  SproutIconCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/17/21.
//

import UIKit

class SproutIconCell: UICollectionViewCell {
    func defaultConfigurtion() -> IconCellContentConfiguration {
        var config = IconCellContentConfiguration()
        config.tintColor = .systemBlue
        config.symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 100, weight: .bold)
        return  config
    }
}

struct IconCellContentConfiguration: UIContentConfiguration, Hashable {
    var image: UIImage?
    var tintColor: UIColor?
    var symbolConfiguration: UIImage.SymbolConfiguration?

    static func ImageConfiguration(image: UIImage) -> IconCellContentConfiguration {
        return IconCellContentConfiguration(image: image, tintColor: nil, symbolConfiguration: nil)
    }

    static func SymbolConfiguration(symbolName: String, tintColor: UIColor? = nil, preferredConfiguration: UIImage.SymbolConfiguration? = nil) -> IconCellContentConfiguration {
        return IconCellContentConfiguration(image: UIImage(systemName: symbolName), tintColor: tintColor, symbolConfiguration: preferredConfiguration)
    }

    func makeContentView() -> UIView & UIContentView {
        return IconCellContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> IconCellContentConfiguration {
        return self
    }
}

class IconCellContentView: UIView & UIContentView {
    let plantIconView = SproutIconView()

    var iconConfiguration: SproutIconConfiguration {
        get { plantIconView.configuration }
        set { plantIconView.configuration = newValue }
    }

    init(configuration: IconCellContentConfiguration) {
        super.init(frame: .zero)
        self.configuration = configuration
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var configuration: UIContentConfiguration {
        get { appliedContentConfiguration }
        set {
            guard let newConfig = newValue as? IconCellContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }

    private func setupView() {
        addSubview(plantIconView)
        plantIconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            plantIconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            plantIconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            plantIconView.heightAnchor.constraint(equalTo: heightAnchor),
            plantIconView.widthAnchor.constraint(equalTo: plantIconView.heightAnchor),
        ])
    }

    private var appliedContentConfiguration: IconCellContentConfiguration!
    private func apply(configuration: IconCellContentConfiguration) {
        guard appliedContentConfiguration != configuration else { return }
        appliedContentConfiguration = configuration
        
        // configure view
        var config = plantIconView.defaultConfiguration()
        config.image = appliedContentConfiguration.image
        config.tintColor = appliedContentConfiguration.tintColor
        config.symbolConfiguration = appliedContentConfiguration.symbolConfiguration

        iconConfiguration = config
    }
}
