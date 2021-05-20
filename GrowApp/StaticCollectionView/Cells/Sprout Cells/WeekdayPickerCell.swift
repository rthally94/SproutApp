//
//  WeekPickerCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/20/21.
//

import UIKit

class WeekdayPickerCell: UICollectionViewCell {
    var weekPicker = ImagePicker()

    private var customConstraints: (
        pickerTop: NSLayoutConstraint,
        pickerLeading: NSLayoutConstraint,
        pickerBottom: NSLayoutConstraint,
        pickerTrailing: NSLayoutConstraint
    )?

    override func layoutSubviews() {
        super.layoutSubviews()

        setupViewsIfNeeded()
    }

    private func setupViewsIfNeeded() {
        guard customConstraints == nil else { return }

        contentView.addSubview(weekPicker)
        weekPicker.translatesAutoresizingMaskIntoConstraints = false

        let constraints = (
            pickerTop: weekPicker.topAnchor.constraint(equalTo: contentView.topAnchor),
            pickerLeading: weekPicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pickerBottom: weekPicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            pickerTrailing: weekPicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        )

        NSLayoutConstraint.activate([
            constraints.pickerTop,
            constraints.pickerLeading,
            constraints.pickerBottom,
            constraints.pickerTrailing
        ])

        customConstraints = constraints
    }
}
