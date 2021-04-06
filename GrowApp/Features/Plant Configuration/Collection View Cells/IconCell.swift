//
//  ImageCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/17/21.
//

import UIKit

class IconCell: UICollectionViewCell {
    func defaultConfigurtion() -> IconCellContentConfiguration {
        var config = IconCellContentConfiguration()
        config.tintColor = .systemBlue
        config.image = nil
        return config
    }
}

struct IconCellContentConfiguration: UIContentConfiguration, Hashable {
    var image: UIImage?
    var tintColor: UIColor?
    
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
    
    private let plantIcon = IconView()
    
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
    
    private var appliedContentConfiguration: IconCellContentConfiguration!
    private func apply(configuration: IconCellContentConfiguration) {
        guard appliedContentConfiguration != configuration else { return }
        appliedContentConfiguration = configuration
        
        // configure view
        var config = plantIcon.defaultConfiguration()
        config.image = appliedContentConfiguration.image
        config.tintColor = appliedContentConfiguration.tintColor
        plantIcon.iconViewConfiguration = config
    }
}
