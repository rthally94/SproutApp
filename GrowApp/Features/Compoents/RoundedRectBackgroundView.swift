//
//  RoundedRectBackground.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/3/21.
//

import UIKit

class RoundedRectBackgroundView: UICollectionReusableView {
    static let ElementKind = "ElementKindRoundedRectBackgroundView"
    var cornerRadius: CGFloat = 10

    private lazy var insetView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .clear

        addSubview(insetView)
        insetView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            insetView.topAnchor.constraint(equalTo: topAnchor),
            insetView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            insetView.bottomAnchor.constraint(equalTo: bottomAnchor),
            insetView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
}
