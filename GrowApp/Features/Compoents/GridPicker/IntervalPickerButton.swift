//
//  TappableView.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/20/21.
//

import UIKit

class IntervalPickerButton: UIControl {
    private var _backgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = view.bounds.height/2
        view.clipsToBounds = true
        return view
    }()

    private var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    var text: String? {
        get { textLabel.text }
        set { textLabel.text = newValue }
    }

    override var isSelected: Bool {
        didSet {
            updateUI()
        }
    }

    override var tintColor: UIColor! {
        didSet {
            updateUI()
        }
    }

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewsIfNeeded()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViewsIfNeeded()
    }


    override func layoutSubviews() {
        super.layoutSubviews()

        _backgroundView.layer.cornerRadius = bounds.height/2.0
        _backgroundView.clipsToBounds = true
    }

    private func setupViewsIfNeeded() {
        addSubview(_backgroundView)
        addSubview(textLabel)
        _backgroundView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        _backgroundView.pinToBoundsOf(self)
        textLabel.pinToLayoutMarginsOf(self)
    }

    private func updateUI() {
        _backgroundView.isHidden = !isSelected

        let bgColor = isSelected ? tintColor : .secondarySystemGroupedBackground
        _backgroundView.backgroundColor = bgColor
        textLabel.textColor = UIColor.labelColor(against: bgColor)
    }
}
