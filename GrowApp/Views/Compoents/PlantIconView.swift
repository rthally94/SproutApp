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
    private var background: RoundedRect! = nil

    init() {
        super.init(frame: .zero)
        configureHiearchy()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PlantIconView {
    private func configureHiearchy() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 56, weight: .semibold)

        textLabel = UILabel()
        textLabel.font = UIFont.systemFont(ofSize: 56)
        textLabel.textAlignment = .center

        background = RoundedRect()
        background.tintColor = .systemBlue

        addSubview(background)
        addSubview(textLabel)
        addSubview(imageView)


        textLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        background.translatesAutoresizingMaskIntoConstraints = false

        let scale: CGFloat = 0.6

        NSLayoutConstraint.activate([
            background.centerYAnchor.constraint(equalTo: centerYAnchor),
            background.centerXAnchor.constraint(equalTo: centerXAnchor),
            background.heightAnchor.constraint(equalTo: heightAnchor),
            background.widthAnchor.constraint(equalTo: heightAnchor),

            imageView.centerYAnchor.constraint(equalTo: background.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: background.centerXAnchor),
            imageView.heightAnchor.constraint(equalTo: background.heightAnchor, multiplier: scale),
            imageView.widthAnchor.constraint(equalTo: background.widthAnchor, multiplier: scale),

            textLabel.centerYAnchor.constraint(equalTo: background.centerYAnchor),
            textLabel.centerXAnchor.constraint(equalTo: background.centerXAnchor),
            textLabel.heightAnchor.constraint(equalTo: background.heightAnchor, multiplier: scale),
            textLabel.widthAnchor.constraint(equalTo: background.widthAnchor, multiplier: scale),
        ])
    }
}
