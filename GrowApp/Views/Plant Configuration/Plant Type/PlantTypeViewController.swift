//
//  PlantTypeViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/24/21.
//

import UIKit

class PlantTypeViewController: UIViewController {
    
    let picker = PlantTypePicker(frame: .zero)
        
    override func loadView() {
        super.loadView()
        configureHiearchy()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func configureHiearchy() {
        self.view = picker
    }
}
