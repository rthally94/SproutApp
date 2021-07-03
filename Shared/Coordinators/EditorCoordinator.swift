//
//  EditorCoordinator.swift
//  Sprout
//
//  Created by Ryan Thally on 6/30/21.
//

import CoreData
import UIKit
import SproutKit

protocol EditorCoordinatorDelegate: AnyObject {
    func editorCoordinator(_ coordinator: EditorCoordinator, didUpdatePlant plant: SproutPlantMO)
    func editorCoordinatorDidFinish(_ coordinator: EditorCoordinator)
}

final class EditorCoordinator: Coordinator {
    weak var delegate: EditorCoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var managedObjectContext: NSManagedObjectContext
    var plantID: NSManagedObjectID

    init?(navigationController: UINavigationController,
         plant: SproutPlantMO) {

        guard let context = plant.managedObjectContext else { return nil }
        self.navigationController = navigationController
        self.managedObjectContext = context
        self.plantID = plant.objectID
    }

    func start() {
        guard let plant = try? managedObjectContext.existingObject(with: plantID) as? SproutPlantMO else {
            delegate?.editorCoordinatorDidFinish(self)
            return
        }

        let vc = AddEditPlantViewController(plant: plant, editingContext: managedObjectContext)
        vc.delegate = self

        navigationController.pushViewController(vc, animated: false)
    }
}

extension EditorCoordinator: AddEditPlantViewControllerDelegate {
    func plantEditor(_ editor: AddEditPlantViewController, didUpdatePlant plant: SproutPlantMO) {
        delegate?.editorCoordinator(self, didUpdatePlant: plant)
    }

    func plantEditorDidFinish(_ editor: AddEditPlantViewController) {
        delegate?.editorCoordinatorDidFinish(self)
    }
}
