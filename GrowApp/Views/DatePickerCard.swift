//
//  BottomCard.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/20/21.
//

import UIKit

class DatePickerCard: UIView {
    let background = RoundedRectContainer(cornerRadius: 20, frame: .zero)
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    let datePicker = UIDatePicker()
    let doneButton = UIButton(type: .system)
    
    func configureTitleLabel() {
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title3)
    }
    
    func configureDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
    }
    
    func configureDoneButton() {
        doneButton.setTitle("Done", for: .normal)
        doneButton.backgroundColor = .systemBlue
    }
    
    func configureHiearchy() {
        background.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(background)
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: topAnchor),
            background.leadingAnchor.constraint(equalTo: leadingAnchor),
            background.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            // Offset below screen
            background.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: background.layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: background.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: background.layoutMarginsGuide.trailingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1.0),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: background.layoutMarginsGuide.trailingAnchor),
        ])
        
        addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalToSystemSpacingBelow: subtitleLabel.bottomAnchor, multiplier: 1.0),
            datePicker.leadingAnchor.constraint(equalTo: background.layoutMarginsGuide.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: background.layoutMarginsGuide.trailingAnchor),
        ])
        
        addSubview(doneButton)
        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalToSystemSpacingBelow: datePicker.bottomAnchor, multiplier: 1.5),
            doneButton.centerXAnchor.constraint(equalTo: background.centerXAnchor),
            doneButton.widthAnchor.constraint(lessThanOrEqualTo: background.layoutMarginsGuide.widthAnchor, multiplier: 1.0),
            doneButton.bottomAnchor.constraint(equalTo: background.layoutMarginsGuide.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK:- View Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureTitleLabel()
        configureDatePicker()
        configureDoneButton()
        configureHiearchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
