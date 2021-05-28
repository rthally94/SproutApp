//
//  PlantIconPickerDelegate.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/5/21.
//

import Foundation

protocol PlantIconPickerControllerDelegate: AnyObject {
    func plantIconPicker(_ picker: PlantIconPickerController, didSelectIcon icon: SproutIcon)
    func plantIconPickerDidCancel(_ picker: PlantIconPickerController)
}

extension PlantIconPickerControllerDelegate {
    func plantIconPicker(_ picker: PlantIconPickerController, didSelectIcon icon: SproutIcon) { }
    func plantIconPickerDidCancel(_ picker: PlantIconPickerController) { }
}
