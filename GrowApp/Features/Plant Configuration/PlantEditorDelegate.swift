//
//  PlantConfigurationDelegate.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/2/21.
//

import Foundation

protocol PlantEditorDelegate: class {
    func plantEditor(_ editor: PlantConfigurationViewController, didUpdatePlant plant: GHPlant)
    func plantEditorDidCancel(_ editor: PlantConfigurationViewController)
}

extension PlantEditorDelegate {
    func plantEditor(_ editor: PlantConfigurationViewController, didUpdatePlant plant: GHPlant) { }
    func plantEditorDidCancel(_ editor: PlantConfigurationViewController) { }
}
