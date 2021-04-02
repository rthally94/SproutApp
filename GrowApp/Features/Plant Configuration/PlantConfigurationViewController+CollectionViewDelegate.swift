//
//  PlantConfigurationViewController+CollectionViewDelegate.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/21/21.
//

import UIKit

extension PlantConfigurationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let item = dataSource.itemIdentifier(for: indexPath)
        return item?.action != nil
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource.itemIdentifier(for: indexPath)
        if let action = item?.action {
            selectedIndexPath = indexPath

            action()
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
