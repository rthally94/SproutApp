//
//  DatePickerCardViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/21/21.
//

import UIKit

class DatePickerCardViewController: UIViewController {
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
    }
}
