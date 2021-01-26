//
//  PlantConfigurationViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/24/21.
//

import UIKit

struct FormSection {
    let headerText: String?
    let cells: [FormCell]
}

struct FormModel {
    // Section 1
    var plantName: String = ""
    
    // Section 3
    var isWateringEnabled: Bool = false
    var wateringMethod: String = ""
    var wateringFrequency: String = ""
}

class PlantConfigurationViewController: UITableViewController {
    var sections = [FormSection]()
    var state = FormModel() {
        didSet {
            print(state)
            buildSections()
            
            tableView.beginUpdates()
            
            if state.isWateringEnabled {
                tableView.insertRows(at: [IndexPath(row: 1, section: 2), IndexPath(row: 2, section: 2)], with: .automatic)
            } else {
                tableView.deleteRows(at: [IndexPath(row: 1, section: 2), IndexPath(row: 2, section: 2)], with: .automatic)
            }
            
            tableView.endUpdates()
        }
    }
    
    func buildSections() {
        sections = [
            FormSection(headerText: nil, cells: [
                TextFieldTableViewCell(placeholder: "Plant Name"),
            ]),
            FormSection(headerText: nil, cells: [
                ToggleTableViewCell(image: UIImage(systemName: "bell.fill"), title: "Reminders") {
                    
                },
            ])
        ]
        
        var wateringSectionCells: [FormCell] = [
            ToggleTableViewCell(image: UIImage(systemName: "drop.fill"), title: "Watering") { [unowned self] in
                state.isWateringEnabled.toggle()
            }
        ]
        
        if state.isWateringEnabled {
            wateringSectionCells += [
                TextFieldTableViewCell(placeholder: "Method"),
                TextFieldTableViewCell(placeholder: "Frequency"),
            ]
        }
        
        let wateringSection = FormSection(headerText: "Care Info", cells: wateringSectionCells)
        sections.append(wateringSection)
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        buildSections()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        buildSections()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return sections[indexPath.section].cells[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return sections[indexPath.section].cells[indexPath.row].shouldHighlight
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].headerText
    }
}
