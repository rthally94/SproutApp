//
//  ImageCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/17/21.
//

import UIKit

class PlantIconCell: UICollectionViewCell {
    var icon: GHIcon? {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        var content = PlantIconContentConfiguration().updated(for: state)
        
        content.icon = icon
        
        contentConfiguration = content
    }
}

struct PlantIconContentConfiguration: UIContentConfiguration, Hashable {
    var icon: GHIcon? = nil
    
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
    
    private var appliedContentConfiguration: PlantIconContentConfiguration!
    private func apply(configuration: PlantIconContentConfiguration) {
        guard appliedContentConfiguration != configuration else { return }
        appliedContentConfiguration = configuration
        
        // configure view
        if let icon = configuration.icon {
            var config = plantIcon.defaultConfiguration()
            config.icon = icon
            plantIcon.iconViewConfiguration = config
        }
    }
}
