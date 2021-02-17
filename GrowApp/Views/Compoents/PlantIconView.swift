//
//  PlantIconImageView.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/17/21.
//

import UIKit
import CoreGraphics

class PlantIconView: UIView {
    var image: UIImage? {
        didSet {
            guard let image = image else { return }
            imageView.image = image
            textLabel.text = nil
        }
    }

    var text: String? {
        didSet {
            guard let text = text else { return }
            if text.count > 2 {
                let startIndex = text.startIndex
                let endIndex = text.index(after: text.startIndex)
                textLabel.text = String(text[startIndex...endIndex])
            } else {
                textLabel.text = text
            }
            imageView.image = nil
        }
    }

    private var imageView: UIImageView! = nil
    private var textLabel: UILabel! = nil

    init() {
        super.init(frame: .zero)
        configureHiearchy()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = min(bounds.height, bounds.width) / 2
    }
}

extension PlantIconView {
    private func configureHiearchy() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit

        textLabel = UILabel()
        textLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        textLabel.textAlignment = .center

        addSubview(textLabel)
        addSubview(imageView)

        textLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            imageView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),

            textLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            textLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            textLabel.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
            textLabel.widthAnchor.constraint(equalTo: layoutMarginsGuide.widthAnchor)
        ])
    }
}
