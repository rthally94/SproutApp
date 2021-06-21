//
//  DayOfMonthPicker.swift
//  Sprout
//
//  Created by Ryan Thally on 6/10/21.
//

import UIKit

class DayOfMonthPicker: UIControl {
    static let dayRange = Array(1...31)
    static let itemsPerRow = 7
    static var numberOfRows: Int { (dayRange.count % itemsPerRow) + 1 }
    static let rowSpacing: CGFloat = 8

    func makeCalendarGrid() -> UIStackView {
        let rowStacks: [UIStackView] = Array(0..<Self.numberOfRows).map { rowIndex in
            let items: [UIButton] = Array(0..<Self.itemsPerRow).map { columnIndex in
                let index = (rowIndex * Self.itemsPerRow) + columnIndex
                let value = index + 1
                return makeButton(dayValue: value)
            }

            let rowStack = UIStackView(arrangedSubviews: items)
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.alignment = .fill
            rowStack.spacing = Self.rowSpacing
            return rowStack
        }

        let rootStack = UIStackView(arrangedSubviews: rowStacks)
        rootStack.axis = .vertical
        rootStack.distribution = .fillEqually
        rootStack.alignment = .fill
        rootStack.spacing = Self.rowSpacing

        return rootStack
    }

    private(set) var selection: Set<Int> = []
    var minimumSelectionCount: Int = 1

    private lazy var calendarGrid = makeCalendarGrid()

    // MARK: - Initialziers
    convenience init(initialSelection: Set<Int>) {
        self.init(frame: .zero)
        selection = initialSelection
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        addSubview(calendarGrid)
        calendarGrid.translatesAutoresizingMaskIntoConstraints = false

        let gridBottom = calendarGrid.bottomAnchor.constraint(equalTo: bottomAnchor)
        gridBottom.priority-=1

        NSLayoutConstraint.activate([
            calendarGrid.topAnchor.constraint(equalTo: topAnchor),
            calendarGrid.leadingAnchor.constraint(equalTo: leadingAnchor),
            gridBottom,
            calendarGrid.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    // MARK: - Actions
    func setSelection(_ selection: Set<Int>) {
        guard selection.count >= minimumSelectionCount else { return }
        let changes = self.selection.symmetricDifference(selection)
        self.selection = selection

        for change in changes {
            let column = (change-1) % 7
            let row = (change-1) / 7

            let rowStack = calendarGrid.arrangedSubviews[row] as! UIStackView
            let button = rowStack.arrangedSubviews[column] as! SproutCapsuleButton

            button.isSelected = selection.contains(change)
        }
    }

    private func buttonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        if self.selection.contains(sender.tag) {
            guard self.selection.count > self.minimumSelectionCount else { return }
            self.selection.remove(sender.tag)
        } else {
            self.selection.insert(sender.tag)
        }

        self.sendActions(for: .valueChanged)
    }
}

private extension DayOfMonthPicker {
    func makeButton(dayValue: Int) -> UIButton {
        let action = UIAction() { [unowned self] action in
            guard let sender = action.sender as? UIButton else { return }
            self.buttonTapped(sender)
        }

        let button = SproutCapsuleButton(type: .custom, primaryAction: action)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalTo: button.widthAnchor),
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 34)
        ])

        button.tag = dayValue
        button.setTitle("\(dayValue)", for: .normal)

        return button
    }
}
