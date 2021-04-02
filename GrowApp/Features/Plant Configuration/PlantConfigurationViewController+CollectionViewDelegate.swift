//
//  PlantConfigurationViewController+CollectionViewDelegate.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/21/21.
//

import UIKit

extension PlantConfigurationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        let itemID = dataSource.itemIdentifier(for: indexPath)
//        return itemID?.onTap != nil
        return false
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let itemID = dataSource.itemIdentifier(for: indexPath)
//        if let strongOnTap = itemID?.onTap {
//            selectedIndexPath = indexPath
//
//            strongOnTap()
//        }
    }

    func navigateTo(_ destination: UIViewController, modal: Bool = false) {
        if let navigationController = navigationController, modal == false {
            navigationController.pushViewController(destination, animated: true)
        } else {
            present(destination, animated: true)
        }
    }
}
