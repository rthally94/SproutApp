//
//  PlantIconPickerDelegate.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/5/21.
//

import Foundation

protocol PlantIconPickerControllerDelegate: class {
    func plantIconPicker(_ picker: PlantIconPickerController, didSelectIcon icon: GHIcon)
    func plantIconPickerDidCancel(_ picker: PlantIconPickerController)
}

extension PlantIconPickerControllerDelegate {
    func plantIconPicker(_ picker: PlantIconPickerController, didSelectIcon icon: GHIcon) { }
    func plantIconPickerDidCancel(_ picker: PlantIconPickerController) { }
}
