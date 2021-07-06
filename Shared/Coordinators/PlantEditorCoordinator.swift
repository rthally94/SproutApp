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
    func editorCoordinator(_ coordinator: PlantEditorCoordinator, didUpdatePlant plant: SproutPlantMO)
    func editorCoordinatorDidFinish(_ coordinator: PlantEditorCoordinator)
}

final class PlantEditorCoordinator: NSObject, EditPlantCoordinator {
    weak var delegate: EditorCoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var managedObjectContext: NSManagedObjectContext
    var plantID: NSManagedObjectID
    var plant: SproutPlantMO? {
        return try? managedObjectContext.existingObject(with: plantID) as? SproutPlantMO
    }

    init?(navigationController: UINavigationController,
         plant: SproutPlantMO) {

        guard let context = plant.managedObjectContext else { return nil }
        self.navigationController = navigationController
        self.managedObjectContext = context
        self.plantID = plant.objectID

        super.init()
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

    func showImagePicker(source: UIImagePickerController.SourceType) {
        let vc = UIImagePickerController()
        vc.delegate = self

        guard UIImagePickerController.isSourceTypeAvailable(source) else {
            print("\(#function) - UIImagePicker.SourceType is unavailable: \(source)")
            return
        }
        vc.sourceType = source
        navigationController.present(vc, animated: true)
    }

    func showPlantTypePicker(currentType: SproutPlantTemplate?) {
        let vc = PlantTypePickerViewController()
        vc.delegate = self
        vc.selectedType = currentType

        navigationController.pushViewController(vc, animated: true)
    }

    func edit(task: SproutCareTaskMO) {
        let vc = TaskEditorViewController(task: task, editingContext: managedObjectContext)
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }

    private func updateRootVC(animated: Bool = true) {
        if let rootVC = navigationController.viewControllers.first as? AddEditPlantViewController {
            rootVC.updateUI(animated: animated)
        }
    }
}

extension PlantEditorCoordinator: AddEditPlantViewControllerDelegate {
    func plantEditor(_ editor: AddEditPlantViewController, didUpdatePlant plant: SproutPlantMO) {
        delegate?.editorCoordinator(self, didUpdatePlant: plant)
    }

    func plantEditorDidFinish(_ editor: AddEditPlantViewController) {
        delegate?.editorCoordinatorDidFinish(self)
    }
}

extension PlantEditorCoordinator: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        plant?.setImage(image)
        updateRootVC(animated: false)
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension PlantEditorCoordinator: PlantTypePickerDelegate {
    func plantTypePicker(_ picker: PlantTypePickerViewController, didSelectType plantType: SproutPlantTemplate) {
        plant?.plantTemplate = plantType
        updateRootVC(animated: false)
    }

    func plantTypePickerDidCancel(_ picker: PlantTypePickerViewController) {
        picker.dismiss(animated: true)
    }
}

extension PlantEditorCoordinator: TaskEditorDelegate {
    func taskEditor(_ editor: TaskEditorViewController, didUpdateTask task: SproutCareTaskMO) {
        updateRootVC(animated: false)
    }

    func taskEditorDidCancel(_ editor: TaskEditorViewController) {
        editor.dismiss(animated: true)
    }
}
