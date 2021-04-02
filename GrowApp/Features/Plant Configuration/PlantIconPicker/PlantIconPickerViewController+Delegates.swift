//
//  PlantIconPickerViewController+Delegates.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/23/21.
//

import UIKit

extension PlantIconPickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if let item = dataSource.itemIdentifier(for: indexPath) {
//            item.onTap?()
//        }
    }
}

extension PlantIconPickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showImagePicker(preferredType: UIImagePickerController.SourceType = .photoLibrary) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.mediaTypes = ["public.image"]

        if UIImagePickerController.isSourceTypeAvailable(preferredType) {
            picker.sourceType = preferredType
        } else {
            picker.sourceType = .photoLibrary
        }

        if picker.sourceType == .camera {
            picker.cameraOverlayView = CameraOverlayView(frame: .zero)
        }

        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        icon?.image = image

        dismiss(animated: true)
    }
}
