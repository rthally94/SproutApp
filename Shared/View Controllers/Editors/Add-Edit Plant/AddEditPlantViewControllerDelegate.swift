//
//  PlantConfigurationDelegate.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/2/21.
//

import Foundation
import SproutKit

protocol AddEditPlantViewControllerDelegate: AnyObject {
    func plantEditor(_ editor: AddEditPlantViewController, didUpdatePlant plant: SproutPlantMO)
    func plantEditorDidFinish(_ editor: AddEditPlantViewController, status: DismissStatus)
}
