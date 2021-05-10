//
//  ChipLabel.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/10/21.
//

import UIKit

class SproutChipView: UIView {
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        return label
    }()

    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray
        view.clipsToBounds = true
        view.layer.cornerRadius = bounds.height / 2
        return view
    }()

    var contentInsets: UIEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10) {
        didSet {
            layoutMargins = contentInsets
        }
    }

    override var backgroundColor: UIColor? {
        set {
            backgroundView.backgroundColor = newValue
            textLabel.textColor = UIColor.labelColor(against: newValue)
        }
        get { backgroundView.backgroundColor }
    }

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        addSubview(backgroundView)
        addSubview(textLabel)

        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        layoutMargins = contentInsets

        backgroundView.pinToBoundsOf(self)
        textLabel.pinToLayoutMarginsOf(self)

        let VCHP = contentHuggingPriority(for: .vertical)
        let HCHP = contentHuggingPriority(for: .horizontal)

        setContentHuggingPriority(VCHP+1, for: .vertical)
        setContentHuggingPriority(HCHP+1, for: .horizontal)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if backgroundView.layer.cornerRadius != bounds.height/2 {
            backgroundView.layer.cornerRadius = bounds.height/2
        }
    }
}
