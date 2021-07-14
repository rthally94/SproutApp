//
//  SproutCardView.swift
//  Sprout
//
//  Created by Ryan Thally on 4/28/21.
//

import UIKit

class SproutCardView: UIView {
    let plantIconView = SproutIconView()
    var iconConfiguration: SproutIconConfiguration {
        get { plantIconView.configuration }
        set { plantIconView.configuration = newValue }
    }

    let textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private lazy var contentStack: UIStackView = { [unowned self] in
        let stack = UIStackView(arrangedSubviews: [plantIconView, textLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fillProportionally
        return stack
    }()

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
        addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.pinToBoundsOf(self)

        plantIconView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.75).isActive = true
    }
}
