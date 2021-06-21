//
//  SproutDayOfWeekPickerCellCollectionViewCell.swift
//  Sprout
//
//  Created by Ryan Thally on 6/10/21.
//

import UIKit

class SproutDayOfWeekPickerCollectionViewCell: UICollectionViewCell {
    var valueChangedAction: UIAction? {
        didSet {
            if let oldValue = oldValue {
                dayOfWeekPicker.removeAction(oldValue, for: .valueChanged)
            }

            if let action = valueChangedAction {
                dayOfWeekPicker.addAction(action, for: .valueChanged)
            }
        }
    }

    private weak var dayOfWeekPicker: DayOfWeekPicker!
    func setSelection(_ selection: Set<Int>) {
        dayOfWeekPicker.setSelection(selection)
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
        let dayOfWeekPicker = DayOfWeekPicker(initialSelection: [])
        contentView.addSubview(dayOfWeekPicker)
        dayOfWeekPicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dayOfWeekPicker.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: 5),
            dayOfWeekPicker.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 5),
            dayOfWeekPicker.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor, constant: -5),
            dayOfWeekPicker.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -5)
        ])

        self.dayOfWeekPicker = dayOfWeekPicker

        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = .secondarySystemGroupedBackground
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        setSelection([1])
    }
}
