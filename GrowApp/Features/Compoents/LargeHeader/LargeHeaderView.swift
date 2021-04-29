//
//  LargeHeaderView.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/16/21.
//

import UIKit

class LargeHeaderView: UIView {
    static let titleFont = UIFont.preferredFont(forTextStyle: .largeTitle)
    static let valueFont = UIFont.preferredFont(forTextStyle: .footnote)

    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.preferredSymbolConfiguration = .init(font: LargeHeaderView.titleFont)

        let HCHP = view.contentHuggingPriority(for: .horizontal)
        let VCHP = view.contentHuggingPriority(for: .vertical)

        view.setContentHuggingPriority(HCHP+1, for: .horizontal)
        view.setContentHuggingPriority(VCHP+1, for: .vertical)

        return view
    }()

    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = LargeHeaderView.titleFont
        return view
    }()

    lazy var subtitleLabel: UILabel = {
        let view = UILabel()
        view.font = LargeHeaderView.valueFont
        return view
    }()

    override var backgroundColor: UIColor? {
        didSet {
            let textColor = UIColor.labelColor(against: backgroundColor)
            imageView.tintColor = textColor
            titleLabel.textColor = textColor
            subtitleLabel.textColor = textColor
        }
    }

    private var appliedBounds: CGRect? = nil

    override func layoutSubviews() {
        super.layoutSubviews()

        layoutIfAble()
    }
}

private extension LargeHeaderView {
    func layoutIfAble() {
        guard appliedBounds == nil || appliedBounds != bounds else { return }

        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            imageView.firstBaselineAnchor.constraint(equalTo: titleLabel.firstBaselineAnchor),

            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: imageView.trailingAnchor, multiplier: 1.0),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

            subtitleLabel.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1.0),
            subtitleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        ])


    }
}
