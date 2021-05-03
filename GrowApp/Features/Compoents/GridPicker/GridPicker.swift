//
//  GridPicker.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/20/21.
//

import UIKit

class GridPicker: UIControl {
    var itemsPerRow: Int = 7
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
                let button = IntervalPickerButton(primaryAction: action)

//                button.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
                button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true

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
            }

            let remaining = imageButtons.count % itemsPerRow
            if remaining != 0 {
                let rowStack = columnStackView.arrangedSubviews.last as? UIStackView
                for _ in 0...remaining {
                    rowStack?.addArrangedSubview(UIView())
                }
            }

            setNeedsLayout()
        }
    }

    private var rowStackView: UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        return stackView
    }

    private let columnStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 16
        stackView.alignment = .fill
        return stackView
    }()

    private var customConstraints: (
        stackTop: NSLayoutConstraint,
        stackLeading: NSLayoutConstraint,
        stackBotton: NSLayoutConstraint,
        stackTrailing: NSLayoutConstraint
    )?

    override func layoutSubviews() {
        super.layoutSubviews()

        setupViewsIfNeeded()
    }

    private func setupViewsIfNeeded() {
        guard customConstraints == nil else { return }

        addSubview(columnStackView)
        columnStackView.translatesAutoresizingMaskIntoConstraints = false

        let constraints = (
            stackTop: columnStackView.topAnchor.constraint(equalTo: topAnchor),
            stackLeading: columnStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackBotton: columnStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackTrailing: columnStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        )

        constraints.stackTop.priority-=1

        NSLayoutConstraint.activate([
            constraints.stackTop,
            constraints.stackLeading,
            constraints.stackBotton,
            constraints.stackTrailing
        ])

        customConstraints = constraints
    }
}
