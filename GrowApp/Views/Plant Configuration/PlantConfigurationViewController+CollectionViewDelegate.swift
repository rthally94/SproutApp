//
//  PlantConfigurationViewController+CollectionViewDelegate.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/21/21.
//

import UIKit

extension PlantConfigurationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let itemID = dataSource.itemIdentifier(for: indexPath)
        return itemID?.destination != nil
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let itemID = dataSource.itemIdentifier(for: indexPath)
        if let destination = itemID?.destination {
            selectedIndexPath = indexPath
            
            if let navigationController = navigationController {
                navigationController.pushViewController(destination, animated: true)
            } else {
                present(destination, animated: true)
            }
        }
    }
}
