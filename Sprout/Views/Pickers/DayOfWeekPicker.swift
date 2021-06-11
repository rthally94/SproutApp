//
//  DayOfWeekPicker.swift
//  Sprout
//
//  Created by Ryan Thally on 6/10/21.
//

import UIKit

class DayOfWeekPicker: UIControl {
    // MARK: - Properties
    private let weekdayItems = (1...7).reduce(into: [Int: String]()) { items, weekdayInt in
        items[weekdayInt] = Calendar.current.veryShortStandaloneWeekdaySymbols[weekdayInt-1]
    }

    private(set) var selection: Set<Int> = []
    var minimumSelectionCount: Int = 1

    private lazy var weekdayStack: UIStackView = {
        let buttons: [UIButton] = weekdayItems.sorted(by: {$0.key < $1.key}).map { weekday, _ in
            makeButton(weekdayValue: weekday)
        }

        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 8
        return stack
    }()

    // MARK: - Initializers
    convenience init(initialSelection: Set<Int>) {
        self.init(frame: .zero)
        self.selection = initialSelection
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        weekdayStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(weekdayStack)

        let stackBottom = weekdayStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        stackBottom.priority-=1

        NSLayoutConstraint.activate([
            weekdayStack.topAnchor.constraint(equalTo: topAnchor),
            weekdayStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackBottom,
            weekdayStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions
    func setSelection(_ selection: Set<Int>) {
        guard selection.count >= minimumSelectionCount else { return }


        self.selection = selection
        reloadButtons()
    }

    private func reloadButtons() {
        weekdayStack.arrangedSubviews.forEach { view in
            let button = view as! UIButton
            button.isSelected = selection.contains(button.tag)
        }
    }

    private func buttonTapped(_ sender: UIButton) {
        if self.selection.contains(sender.tag) {
            guard self.selection.count > self.minimumSelectionCount else { return }
            self.selection.remove(sender.tag)
        } else {
            self.selection.insert(sender.tag)
        }

        self.sendActions(for: .valueChanged)
        sender.isSelected.toggle()
    }
}

private extension DayOfWeekPicker {
    func makeButton(weekdayValue: Int) -> UIButton {
        let weekdayText = weekdayItems[weekdayValue]

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

        button.tag = weekdayValue
        button.setTitle(weekdayText, for: .normal)

        return button
    }
}
