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
        
        view = datePickerCard
    }
}
