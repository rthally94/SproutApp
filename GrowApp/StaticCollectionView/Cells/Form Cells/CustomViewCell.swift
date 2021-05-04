//
//  CustomViewCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/20/21.
//

import UIKit

class CustomViewCell: UICollectionViewCell {
    var customView: UIView? {
        didSet {
            setupViews()
        }
    }

    func setupViews() {
        guard contentView.subviews.isEmpty, let customView = customView else { return }

        contentView.addSubview(customView)
        customView.frame = contentView.bounds
        customView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        customView?.removeFromSuperview()
        customView = nil
    }
}
