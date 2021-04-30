//
//  WeekdayPicker.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/19/21.
//

import UIKit

class ImagePicker: UIControl {
    static let symbolFont = UIFont.systemFont(ofSize: 24, weight: .regular)

    var selectedIndices = Set<Int>()
    var images: [UIImage] = [] {
        didSet {
            selectedIndices = []

            imageButtons = images.enumerated().map { (index, image) in
                let action = UIAction(image: image, handler: tapHandler(_:))
                let imageButton = UIButton(type: .system, primaryAction: action)
                imageButton.setPreferredSymbolConfiguration(.init(font: ImagePicker.symbolFont), forImageIn: .normal)
//                imageButton.contentMode = .scaleAspectFit
                imageButton.adjustsImageWhenHighlighted = false
                return imageButton
            }
        }
    }

    private func tapHandler(_ action: UIAction) {
        guard let button = action.sender as? UIButton, let buttonIndex = imageButtons.firstIndex(of: button) else { return }

        if selectedIndices.contains(buttonIndex) {
            selectedIndices.remove(buttonIndex)
        } else {
            selectedIndices.insert(buttonIndex)
        }
        sendActions(for: .valueChanged)
    }

    private var imageButtons: [UIButton] = [] {
        didSet {
            oldValue.forEach { $0.removeFromSuperview() }
            imageButtons.forEach {
                selectorStackView.addArrangedSubview($0)
            }
        }
    }

    private let selectorStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }



    private func setupViews() {
        addSubview(selectorStackView)
        selectorStackView.translatesAutoresizingMaskIntoConstraints = false
        selectorStackView.pinToBoundsOf(self)
    }
}
