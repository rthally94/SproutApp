//
//  PlantConfigurationViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/24/21.
//

import UIKit

class PlantConfigurationDriver {
    static let listFormatter: ListFormatter = {
        let formatter = ListFormatter()
        
        return formatter
    }()
    
    var formController: FormController!
    var sections = [FormSection]()
    var state = GrowAppModel.shared.getPlants().first! {
        didSet {
            print(state)
            buildSections()
            formController.sections = sections
        }
    }
    
    func buildSections() {
        let wateringCell = CareInfoCell()
        
        sections = [
            FormSection(headerText: nil, cells: [
                TextFieldTableViewCell(placeholder: "Plant Name"),
            ]),
            FormSection(headerText: "Care Info", cells: [
                wateringCell
            ])
        ]
    }
    
    init() {
        formController = FormController(style: .insetGrouped)
        
        buildSections()
        formController.sections = sections
    }
}
