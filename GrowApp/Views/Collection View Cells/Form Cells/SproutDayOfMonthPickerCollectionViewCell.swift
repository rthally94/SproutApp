//
//  SproutDayOfMonthPickerCollectionViewCell.swift
//  Sprout
//
//  Created by Ryan Thally on 6/11/21.
//

import UIKit

class SproutDayOfMonthPickerCollectionViewCell: UICollectionViewCell {
    static let contentInset: CGFloat = 5
    static let cornerRadius: CGFloat = 10

    var valueChangedAction: UIAction? {
        didSet {
            if let oldValue = oldValue {
                // Remove old action
                dayOfMonthPicker.removeAction(oldValue, for: .valueChanged)
            }

            if let action = valueChangedAction {
                // Set action
                dayOfMonthPicker.addAction(action, for: .valueChanged)
            }
        }
    }

    private lazy var dayOfMonthPicker: DayOfMonthPicker = {
        let picker = DayOfMonthPicker(initialSelection: [1])
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    func setSelection(_ selection: Set<Int>) {
        dayOfMonthPicker.setSelection(selection)
    }

    // MARK: - Initialziers

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupView()
    }

    private func setupView() {
        contentView.addSubview(dayOfMonthPicker)
        NSLayoutConstraint.activate([
            dayOfMonthPicker.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: Self.contentInset),
            dayOfMonthPicker.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: Self.contentInset),
            dayOfMonthPicker.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor, constant: -Self.contentInset),
            dayOfMonthPicker.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -Self.contentInset)
        ])

        clipsToBounds = true
        layer.cornerRadius = Self.cornerRadius
        backgroundColor = .secondarySystemGroupedBackground
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        setSelection([1])
    }

}
