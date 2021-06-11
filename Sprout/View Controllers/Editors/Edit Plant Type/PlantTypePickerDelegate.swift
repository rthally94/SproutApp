//
//  PlantTypePickerDelegate.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/2/21.
//

import Foundation

protocol PlantTypePickerDelegate: AnyObject {
    func plantTypePicker(_ picker: PlantTypePickerViewController, didSelectType plantType: SproutPlantMO)
    func plantTypePickerDidCancel(_ picker: PlantTypePickerViewController)
}

extension PlantTypePickerDelegate {
    func plantTypePicker(_ picker: PlantTypePickerViewController, didSelectType plantType: SproutPlantMO) { }
    func plantTypePickerDidCancel(_ picker: PlantTypePickerViewController) { }
}
