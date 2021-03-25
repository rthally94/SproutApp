//
//  DatePickerCardViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/21/21.
//

import UIKit

protocol DatePickerDelegate {
    func didSelect(date: Date)
}

class DatePickerCardViewController: UIViewController {
    var delegate: DatePickerDelegate?
    var selectedDate: Date? {
        didSet {
            if let date = selectedDate {
                datePickerCard.datePicker.date = date
            }
        }
    }

    var datePickerCard = DatePickerCard()
    
    override func loadView() {
        super.loadView()
        
        datePickerCard.delegate = self
        view = datePickerCard
    }
}

extension DatePickerCardViewController: DatePickerCardDelegate {
    func didSelect(date: Date) {
        self.dismiss(animated: true)
        delegate?.didSelect(date: date)
    }
}
