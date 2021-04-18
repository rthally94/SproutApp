//
//  PlantTypePickerDelegate.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/2/21.
//

import Foundation

protocol PlantTypePickerDelegate: class {
    func plantTypePicker(_ picker: PlantTypePickerViewController, didSelectType plantType: GHPlantType)
    func plantTypePickerDidCancel(_ picker: PlantTypePickerViewController)
}

extension PlantTypePickerDelegate {
    func plantTypePicker(_ picker: PlantTypePickerViewController, didSelectType plantType: GHPlantType) { }
    func plantTypePickerDidCancel(_ picker: PlantTypePickerViewController) { }
}
