//
//  PlantIconImageView.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/17/21.
//

import UIKit
import CoreGraphics

class PlantIconView: UIView {
    var icon: PlantIcon? {
        didSet {
            guard let icon = icon, icon != oldValue else { return }
            switch icon {
                case let .emoji(emoji, backgroundColor):
                    text = emoji
                    self.backgroundColor = backgroundColor?.withAlphaComponent(0.5)
                    presentationMode = .padded(multiplier: 0.6, points: 0)
                case let .text(text, foregroundColor, backgroundColor):
                    self.text = text
                    tintColor = foregroundColor ?? backgroundColor?.withAlphaComponent(1.0)
                    self.backgroundColor = backgroundColor?.withAlphaComponent(0.5)
                    presentationMode = .padded(multiplier: 0.6, points: 0)
                case let .symbol(name, foregroundColor, backgroundColor):
                    self.image = UIImage(systemName: name)
                    tintColor = foregroundColor ?? backgroundColor?.withAlphaComponent(1.0)
                    self.backgroundColor = backgroundColor?.withAlphaComponent(0.5)
                    presentationMode = .padded(multiplier: 0.6, points: 0)
                case let .image(image):
                    self.image = image
                    presentationMode = .full
            }
        }
    }

    var image: UIImage? {
        didSet {
            guard image != oldValue else { return }
            guard let image = image else { return }
            imageView.image = image
            textLabel.text = nil
        }
    }

    var text: String? {
        didSet {
            guard text != oldValue else { return }
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

    var iconMode: IconMode = .circle {
        didSet {
            guard iconMode != oldValue else { return }
            setNeedsLayout()
        }
    }

    var presentationMode: PresentationMode? {
        didSet {
            guard presentationMode != oldValue else { return }
            switch presentationMode {
                case let .padded(multiplier, points):
                    scaledConstraint.isActive = false
                    scaledConstraint = imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: multiplier, constant: points)
                    scaledConstraint.isActive = true
                    fullConstraint.isActive = false
                case .full:
                    scaledConstraint.isActive = false
                    fullConstraint.isActive = true
                case .none:
                    scaledConstraint.isActive = false
                    fullConstraint.isActive = true
            }
        }
    }

    enum IconMode: Hashable {
        case circle
        case roundedRect
        case none
    }

    enum PresentationMode: Hashable {
        case padded(multiplier: CGFloat, points: CGFloat)
        case full
    }

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.textAlignment = .center
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }()

    private lazy var fullConstraint: NSLayoutConstraint = imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0, constant: 0.0)
    private lazy var scaledConstraint: NSLayoutConstraint = imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6, constant: 0.0)

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

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

        clipsToBounds = true
    }
}

extension PlantIconView {
    private func configureHiearchy() {
        addSubview(textLabel)
        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            fullConstraint,
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),

            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.widthAnchor.constraint(equalTo: imageView.widthAnchor),
            textLabel.heightAnchor.constraint(equalTo: imageView.heightAnchor),
        ])
    }
}
