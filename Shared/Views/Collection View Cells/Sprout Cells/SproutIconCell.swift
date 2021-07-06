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
    init(configuration: IconCellContentConfiguration) {
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
            guard let newConfig = newValue as? IconCellContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }
    
    private let plantIcon = SproutIconView()
    
    func setupInternalViews() {
        addSubview(plantIcon)
        plantIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            plantIcon.centerXAnchor.constraint(equalTo: centerXAnchor),
            plantIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            plantIcon.heightAnchor.constraint(equalTo: heightAnchor),
            plantIcon.widthAnchor.constraint(equalTo: plantIcon.heightAnchor),
        ])

        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 5
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.width/2).cgPath
    }
    
    private var appliedContentConfiguration: IconCellContentConfiguration!
    private func apply(configuration: IconCellContentConfiguration) {
        guard appliedContentConfiguration != configuration else { return }
        appliedContentConfiguration = configuration
        
        // configure view
        var config = plantIcon.defaultConfiguration()
        config.image = appliedContentConfiguration.image
        config.tintColor = appliedContentConfiguration.tintColor
        config.symbolConfiguration = appliedContentConfiguration.symbolConfiguration

        plantIcon.configuration = config
    }
}
