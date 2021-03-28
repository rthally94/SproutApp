//
//  PlantIconSupplementaryView.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/23/21.
//

import UIKit

class PlantIconSupplementaryView: UICollectionReusableView {
    static let badgeElementKind = String(describing: PlantIconSupplementaryView.self)

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureHiearchy()

        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = min(frame.height, frame.width)/2
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func configureHiearchy() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
