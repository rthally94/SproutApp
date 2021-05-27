//
//  CareInfoTableViewCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/24/21.
//

import UIKit

class CareInfoCollectionViewCell: UICollectionViewCell {
    static let placeholderTintColor = UIColor.systemBlue
    static let placeholderIcon = UIImage(systemName: "exclamationmark.circle.fill")
    static let placeholderTitleText = "Care Info Cell"
    static let placeholderDetailText = "Tap to configure"

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!

    let careScheduleFormatter = Utility.currentScheduleFormatter

    func updateWith(careInfoItem: CareInfo? = nil) {
        iconImageView.tintColor = careInfoItem?.careCategory?.icon?.color ?? Self.placeholderTintColor
        iconImageView.image = careInfoItem?.careCategory?.icon?.image ?? Self.placeholderIcon

        titleLabel.text = careInfoItem?.careCategory?.name ?? Self.placeholderTitleText

        if let currentSchedule = careInfoItem?.currentSchedule {
            detailLabel.text = careScheduleFormatter.string(for: currentSchedule)
        } else {
            detailLabel.text = Self.placeholderDetailText
        }
    }
}
