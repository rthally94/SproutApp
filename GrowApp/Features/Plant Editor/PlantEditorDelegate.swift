//
//  PlantConfigurationDelegate.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/2/21.
//

import Foundation

protocol PlantEditorDelegate: AnyObject {
    func plantEditor(_ editor: PlantEditorControllerController, didUpdatePlant plant: GHPlant)
    func plantEditorDidCancel(_ editor: PlantEditorControllerController)
}

extension PlantEditorDelegate {
    func plantEditor(_ editor: PlantEditorControllerController, didUpdatePlant plant: GHPlant) { }
    func plantEditorDidCancel(_ editor: PlantEditorControllerController) { }
}
