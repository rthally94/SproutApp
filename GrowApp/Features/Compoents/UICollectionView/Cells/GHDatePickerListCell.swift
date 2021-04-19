//
//  GHDatePickerListCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/9/21.
//

import UIKit

private extension UIConfigurationStateCustomKey {
    static let date = UIConfigurationStateCustomKey("net.thally.ryan.GreenHouseDatePickerListCell.date")
    static let action = UIConfigurationStateCustomKey("net.thally.ryan.GreenHouseDatePickerListCell.action")
}

private extension UICellConfigurationState {
    var date: Date? {
        set { self[.date] = newValue }
        get { return self[.date] as? Date }
    }
    
    var action: UIAction? {
        set { self[.action] = newValue }
        get { self[.action] as? UIAction }
    }
}

class GreenHouseDatePickerListCell: UICollectionViewListCell {
    private var date: Date?
    private var action: UIAction?
    
    func updateWith(date newDate: Date, action newAction: UIAction?) {
        guard date != newDate || action != newAction else { return }
        date = newDate
        action = newAction
        setNeedsUpdateConfiguration()
    }
    
    override var configurationState: UICellConfigurationState {
        var state = super.configurationState
        state.date = date
        state.action = action
        return state
    }
}

class DatePickerListCell: GreenHouseDatePickerListCell {
    private func defaultListContentConfiguration() -> UIListContentConfiguration { return .valueCell() }
    private lazy var listContentView = UIListContentView(configuration: defaultListContentConfiguration())
    
    lazy var datePicker = UIDatePicker(frame: .zero)
    
    private var customViewConstraints: (datePickerLeading: NSLayoutConstraint, datePickerTop: NSLayoutConstraint, datePickerBottom: NSLayoutConstraint, datePickerCenterX: NSLayoutConstraint)?
    
    private func setupViewsIfNeeded() {
        guard customViewConstraints == nil else { return }
        configureDatePicker()
        contentView.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = (
            datePickerLeading: datePicker.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor),
            datePickerTop: datePicker.topAnchor.constraint(equalTo: contentView.topAnchor),
            datePickerBottom: datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            datePickerCenterX: datePicker.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        )
        
        constraints.datePickerBottom.priority-=1
        
        NSLayoutConstraint.activate([
            constraints.datePickerTop,
            constraints.datePickerBottom,
            constraints.datePickerLeading,
            constraints.datePickerCenterX,
        ])
        
        customViewConstraints = constraints
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        setupViewsIfNeeded()
        
        if let date = state.date {
            datePicker.date = date
        }
        
        if let action = state.action {
            datePicker.addAction(action, for: .valueChanged)
        }
    }
    
    private func configureDatePicker() {
        datePicker.calendar = Calendar.current
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
    }
}
