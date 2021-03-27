//
//  SymbolIconView.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/27/21.
//

import UIKit

class SymbolIconView: UIView {
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
            layoutMargins = .init(top: bounds.height*0.6, left: bounds.width*0.6, bottom: bounds.height*0.6, right: bounds.width*0.6)
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(imageView)
            imageView.pinToLayoutMarginsOf(self)
            
            appliedBounds = bounds
        }
    }
}
