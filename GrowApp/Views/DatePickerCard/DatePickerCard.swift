//
//  BottomCard.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/20/21.
//

import UIKit

class DatePickerCard: UIView {
    let background = RoundedRectContainer(cornerRadius: 20, frame: .zero)
    let datePicker = UIDatePicker()
    
    func configureDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
    }
    
    func configureHiearchy() {
        background.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(background)
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: topAnchor),
            background.leadingAnchor.constraint(equalTo: leadingAnchor),
            background.trailingAnchor.constraint(equalTo: trailingAnchor),
            background.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: background.layoutMarginsGuide.topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: background.layoutMarginsGuide.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: background.layoutMarginsGuide.trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: background.layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    // MARK:- View Lifecycle
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHiearchy()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        configureDatePicker()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
