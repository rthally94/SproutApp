//
//  ScheduleView.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/7/21.
//

import UIKit

class ScheduleView: UIView {
    private lazy var buttonStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .equalCentering
        view.alignment = .center
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubviews() {
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonStack)
        buttonStack.pinToBoundsOf(self)
    }
}

extension ScheduleView {
    func addArrangedView(_ view: UIView) {
        buttonStack.addArrangedSubview(view)
    }
    
    func insertArrangedView(_ view: UIView, at index: Int) {
        buttonStack.insertArrangedSubview(view, at: index)
    }
    
    func removeArrangedView(at index: Int) {
        guard index >= buttonStack.arrangedSubviews.startIndex && index < buttonStack.arrangedSubviews.endIndex else { return }
        let view = buttonStack.arrangedSubviews[index]
        buttonStack.removeArrangedSubview(view)
    }
    
    func clearArrangedViews() {
        buttonStack.arrangedSubviews.forEach {
            buttonStack.removeArrangedSubview($0)
        }
    }
}
