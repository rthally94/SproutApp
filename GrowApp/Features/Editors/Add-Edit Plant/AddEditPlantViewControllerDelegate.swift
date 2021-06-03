//
//  PlantConfigurationDelegate.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/2/21.
//

import Foundation

protocol AddEditPlantViewControllerDelegate: AnyObject {
    func plantEditor(_ editor: AddEditPlantViewController, didUpdatePlant plant: SproutPlantMO)
    func plantEditorDidCancel(_ editor: AddEditPlantViewController)
}

extension AddEditPlantViewControllerDelegate {
    func plantEditor(_ editor: AddEditPlantViewController, didUpdatePlant plant: SproutPlantMO) { }
    func plantEditorDidCancel(_ editor: AddEditPlantViewController) { }
}
