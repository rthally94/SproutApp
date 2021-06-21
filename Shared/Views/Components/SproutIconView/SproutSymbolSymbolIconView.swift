//
//  SproutSymbolSymbolIconView.swift
//  Sprout
//
//  Created by Ryan Thally on 3/27/21.
//

import UIKit

class SproutSymbolSymbolIconView: UIView {
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            if imageView.image != newValue {
                imageView.image = newValue
            }
        }
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.preferredSymbolConfiguration = .init(weight: .bold)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureHiearchyIfNeeded()
    }
    
    private var appliedBounds: CGRect? = nil
    private func configureHiearchyIfNeeded() {
        if bounds != appliedBounds {
            let widthInset = (bounds.width * 0.4) / 2
            let heightInset = (bounds.height * 0.4) / 2
            layoutMargins = .init(top: heightInset, left: widthInset, bottom: heightInset, right: widthInset)
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(imageView)
            imageView.pinToLayoutMarginsOf(self)
            
            appliedBounds = bounds
        }
    }
}
