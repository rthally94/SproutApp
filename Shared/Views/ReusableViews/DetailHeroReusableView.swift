//
//  BlurrayImageBackgroundCollectionReusableView.swift
//  Sprout
//
//  Created by Ryan Thally on 6/6/21.
//

import UIKit

class DetailHeroReusableView: UICollectionReusableView {
    var titleText: String? {
        get { view.headerTextView.titleLabel.text }
        set { view.headerTextView.titleLabel.text = newValue }
    }

    var subtitleText: String? {
        get { view.headerTextView.subtitleLabel.text }
        set { view.headerTextView.subtitleLabel.text = newValue }
    }

    func defaultIconConfiguration() -> SproutIconConfiguration {
        view.iconView.defaultConfiguration()
    }

    var iconConfiguration: SproutIconConfiguration {
        get { view.iconView.configuration }
        set { view.iconView.configuration = newValue }
    }

    var backgroundImage: UIImage? {
        get { view.backgroundImageView.image }
        set { view.backgroundImageView.image = newValue }
    }

    private var view = SproutHeroView()
    private var needsLayout = true

    override func layoutSubviews() {
        super.layoutSubviews()

        configureViewsIfNeeded()
    }

    private func configureViewsIfNeeded() {
        guard needsLayout else { return }

        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.pinToBoundsOf(self)

        view.backgroundColor = .clear
        needsLayout = true
    }
}
