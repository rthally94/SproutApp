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
                let endIndex = text.index(after: text.startIndex)
                textLabel.text = String(text[...endIndex])
            } else {
                textLabel.text = text
            }
            imageView.image = nil
        }
    }

    var iconMode: IconMode = .circle

    enum IconMode: Hashable {
        case circle
        case roundedRect
        case none
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

        switch iconMode {
            case .circle:
                layer.cornerRadius = min(frame.height, frame.width) / 2
            case .roundedRect:
                layer.cornerRadius = min(frame.height, frame.width) / 4
            default:
                layer.cornerRadius = 0
        }
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

        addSubview(textLabel)
        addSubview(imageView)

        textLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let scale: CGFloat = 0.6

        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: scale),
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: scale),

            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: scale),
            textLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: scale),
        ])
    }
}
