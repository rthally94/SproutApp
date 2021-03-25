//
//  BottomCard.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/20/21.
//

import UIKit

protocol DatePickerCardDelegate {
    func didSelect(date: Date)
}

class DatePickerCard: UIView {
    let background = RoundedRectContainer(cornerRadius: 20, frame: .zero)
    let datePicker = UIDatePicker()
    lazy var buttons = (
        yesterdayButton: CapsuleButton(
            type: .system,
            primaryAction: UIAction(
                title: "-1",
                handler: { _ in
                    if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) {
                        self.selectDate(yesterday)
                    }
                }
            )
        ),
        todayButton: CapsuleButton(
            type: .system,
            primaryAction: UIAction(
                title: "Today",
                handler: { _ in
                    self.selectDate(Date())
                }
            )
        ),
        tomorrowButton: CapsuleButton(
            type: .system,
            primaryAction: UIAction(
                title: "Tomorrow",
                handler: { _ in
                    if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
                        self.selectDate(tomorrow)
                    }
                }
            )
        )
    )
    
    var delegate: DatePickerCardDelegate?
    
    func configureDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.addTarget(self, action: #selector(dateSelected), for: .valueChanged)
    }
    
    func configureHiearchy() {
        let buttonStack = UIStackView(arrangedSubviews: [buttons.todayButton, buttons.tomorrowButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.alignment = .center
        buttonStack.spacing = 20
        
        background.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(background)
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: topAnchor),
            background.leadingAnchor.constraint(equalTo: leadingAnchor),
            background.trailingAnchor.constraint(equalTo: trailingAnchor),
            background.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        addSubview(datePicker)
        addSubview(buttonStack)
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: background.layoutMarginsGuide.topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: background.layoutMarginsGuide.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: background.layoutMarginsGuide.trailingAnchor),
            
            buttonStack.topAnchor.constraint(equalToSystemSpacingBelow: datePicker.bottomAnchor, multiplier: 1.0),
            buttonStack.leadingAnchor.constraint(equalTo: background.layoutMarginsGuide.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: background.layoutMarginsGuide.trailingAnchor),
            buttonStack.bottomAnchor.constraint(lessThanOrEqualTo: background.layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    // MARK:- Inits
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHiearchy()
    }
    
    // MARK:- View Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureDatePicker()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Actions
    private func selectDate(_ date: Date) {
        if let delegate = delegate {
            delegate.didSelect(date: date)
        }
    }
    
    @objc private func dateSelected() {
        selectDate(datePicker.date)
    }
}
