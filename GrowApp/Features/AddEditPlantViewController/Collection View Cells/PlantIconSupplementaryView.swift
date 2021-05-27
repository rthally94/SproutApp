//
//  PlantIconSupplementaryView.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/23/21.
//

import UIKit

class PlantIconSupplementaryView: UICollectionReusableView {
    static let badgeElementKind = String(describing: PlantIconSupplementaryView.self)

    var image: UIImage? {
        get {
            buttonView.image(for: .normal)
        }
        set {
            if newValue != buttonView.image(for: .normal) {
                buttonView.setImage(newValue, for: .normal)
                setNeedsLayout()
            }
        }
    }
    
    var tapAction: (() -> Void)? {
        didSet {
            if tapAction == nil {
                buttonView.removeTarget(self, action: #selector(onTap), for: .touchUpInside)
            } else {
                buttonView.addTarget(self, action: #selector(onTap), for: .touchUpInside)
            }
        }
    }
    
    private lazy var buttonView: UIButton = {
        let button = UIButton(type: .system)
        button.setPreferredSymbolConfiguration(.init(textStyle: .title3), forImageIn: .normal)
        button.backgroundColor = tintColor
        button.tintColor = .white
        return button
    }()
    
    @objc private func onTap() {
        tapAction?()
    }

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureHiearchy()
        
        let length = min(frame.width, frame.height)
        let inset = length / 4
        
        buttonView.contentEdgeInsets = .init(top: inset, left: inset, bottom: inset, right: inset)
        clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = min(bounds.height, bounds.width) / 2
    }


    private func configureHiearchy() {
        addSubview(buttonView)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.pinToBoundsOf(self)
    }
}
