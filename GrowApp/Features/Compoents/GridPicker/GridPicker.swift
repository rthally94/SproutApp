//
//  GridPicker.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/20/21.
//

import UIKit

class GridPicker: UIControl {
    var itemsPerRow: Int = 7
    var rowHeight: CGFloat = 28

    var selectedIndices = Set<Int>() {
        didSet {
            imageButtons.enumerated().forEach { index, item in
                guard let button = item as? UIButton else { return }
                button.isSelected = selectedIndices.contains(index)
            }
        }
    }

    var items: [String] = [] {
        didSet {
            selectedIndices = []

            imageButtons = items.enumerated().map { (index, item) in
                let action = UIAction(title: item, handler: tapHandler(_:))
                let button = IntervalPickerButton()
                button.isSelected = selectedIndices.contains(index)

                return button
            }
        }
    }

    private func tapHandler(_ action: UIAction) {
        guard let button = action.sender as? UIButton, let buttonIndex = imageButtons.firstIndex(of: button) else { return }

        if selectedIndices.contains(buttonIndex) {
            selectedIndices.remove(buttonIndex)
            button.isSelected = false
        } else {
            selectedIndices.insert(buttonIndex)
            button.isSelected = true
        }

        sendActions(for: .valueChanged)
    }

    private var imageButtons: [UIView] = [] {
        didSet {
            oldValue.forEach { $0.removeFromSuperview() }
            columnStackView.subviews.forEach { $0.removeFromSuperview() }

            imageButtons.forEach { button in
                // Add next row if needed
                if columnStackView.arrangedSubviews.isEmpty {
                    columnStackView.addArrangedSubview(rowStackView)
                } else if let rowStack = columnStackView.arrangedSubviews.last as? UIStackView, rowStack.arrangedSubviews.count == itemsPerRow {
                    columnStackView.addArrangedSubview(rowStackView)
                }

                let rowStack = columnStackView.arrangedSubviews.last as? UIStackView
                rowStack?.addArrangedSubview(button)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.heightAnchor.constraint(equalToConstant: rowHeight).isActive = true
                button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
            }

            let remaining = imageButtons.count % itemsPerRow
            if remaining != 0 {
                let rowStack = columnStackView.arrangedSubviews.last as? UIStackView
                for _ in 0...remaining {
                    let placeholderView = UIView()
                    rowStack?.addArrangedSubview(placeholderView)
                    placeholderView.translatesAutoresizingMaskIntoConstraints = false
                    placeholderView.heightAnchor.constraint(equalToConstant: rowHeight).isActive = true
                    placeholderView.widthAnchor.constraint(equalTo: placeholderView.heightAnchor).isActive = true
                }
            }

            setNeedsLayout()
        }
    }

    private var rowStackView: UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 16
        return stackView
    }

    private let columnStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 16
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
        addSubview(columnStackView)
        columnStackView.frame = bounds
        columnStackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
