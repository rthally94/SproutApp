//
//  SproutLabel.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/30/21.
//

import UIKit

class SproutLabel: UIView {
    enum Style {
        case defaultLabelStyle
        case titleAndIconLabelStyle
        case titleOnlyLabelStyle
        case IconOnlyLabelStyle
    }

    var imageView: UIImageView = {
        let view = UIImageView()

        let HCHP = view.contentHuggingPriority(for: .horizontal)
        let VCHP = view.contentHuggingPriority(for: .vertical)

        view.setContentHuggingPriority(HCHP+1, for: .horizontal)
        view.setContentHuggingPriority(VCHP+1, for: .vertical)

        return view
    }()

    var textLabel = UILabel()

    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView, textLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
    }()

    var icon: String? {
        didSet {
            image = nil
            updateView()
        }
    }

    var image: UIImage? {
        didSet {
            icon = nil
            updateView()
        }
    }

    var text: String? {
        didSet {
            updateView()
        }
    }

    var font: UIFont = UIFont.preferredFont(forTextStyle: .body) {
        didSet {
            updateView()
        }
    }

    var style: Style = .defaultLabelStyle {
        didSet {
            updateView()
        }
    }

    override var tintColor: UIColor! {
        didSet {
            textLabel.textColor = tintColor
            imageView.tintColor = tintColor
        }
    }

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        updateView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        updateView()
    }

    private func setupUI() {
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.pinToBoundsOf(self)
    }

    private func updateView() {
        imageView.preferredSymbolConfiguration = .init(font: font)
        textLabel.font = font

        var newImage: UIImage?
        if let icon = icon {
            newImage = UIImage(named: icon) ?? UIImage(systemName: icon)
        } else if let image = image {
            newImage = image
        }

        imageView.image = newImage
        textLabel.text = text

        switch style {
        case .titleAndIconLabelStyle:
            imageView.isHidden = imageView.image == nil
            textLabel.isHidden = textLabel.text == nil
        case .IconOnlyLabelStyle:
            imageView.isHidden = imageView.image == nil
            textLabel.isHidden = true
        case .titleOnlyLabelStyle:
            imageView.isHidden = true
            textLabel.isHidden = textLabel.text == nil
        default:
            imageView.isHidden = imageView.image == nil
            textLabel.isHidden = textLabel.text == nil
        }
    }
}
