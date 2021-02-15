//
//  FormController.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/26/21.
//

import UIKit

class FormSection {
    var headerText: String?
    let cells: [FormCell]
    
    init(headerText: String?, cells: [FormCell]) {
        self.headerText = headerText
        self.cells = cells
    }
}

class FormController: UITableViewController {
    var sections = [FormSection]()
    
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
