//
//  PlantConfigurationViewController+CollectionViewDelegate.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/21/21.
//

import UIKit

extension PlantEditorControllerController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        return item.isNavigable
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        if let action = item.action {
            selectedIndexPath = indexPath

            action(self)
        }
    }

    func navigateTo(_ destination: UIViewController, modal: Bool = false) {
        if let navigationController = navigationController, modal == false {
            navigationController.pushViewController(destination, animated: true)
        } else {
            present(destination, animated: true)
        }
    }
}
