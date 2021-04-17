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
        return view
    }()

    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = LargeHeaderView.titleFont
        return view
    }()

    lazy var valueLabel: UILabel = {
        let view = UILabel()
        view.font = LargeHeaderView.valueFont
        return view
    }()

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
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(valueLabel)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: imageView.trailingAnchor, multiplier: 1.0),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

            valueLabel.topAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        ])


    }
}
