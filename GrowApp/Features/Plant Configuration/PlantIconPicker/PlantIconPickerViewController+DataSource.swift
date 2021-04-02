//
//  PlantIconPickerViewController+DataSource.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/23/21.
//

import UIKit

extension PlantIconPickerViewController {
    func makeCellRegistration() -> UICollectionView.CellRegistration<PlantIconCell, Item> {
        return UICollectionView.CellRegistration<PlantIconCell, Item>() { cell, indexPath, item in
//            cell.icon = item.icon
        }
    }

    func configureDataSource() {
        let cellRegistration = makeCellRegistration()

        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        dataSource.apply(createSnapshot())
    }

    func createSnapshot() -> NSDiffableDataSourceSnapshot<Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        snapshot.appendSections([.currentImage, .recommended])
        snapshot.appendItems([
            Item(icon: icon)
        ], toSection: .currentImage)

        snapshot.appendItems([
            Item(
                image: UIImage(systemName: "camera"),
                tintColor: .systemBlue
//                onTap: {
//                    self.showImagePicker(preferredType: .camera)
//                }
            ),
            Item(
                image: UIImage(systemName: "photo.on.rectangle"),
                tintColor: .systemBlue
//                onTap: {
//                    self.showImagePicker(preferredType: .photoLibrary)
//                }
            ),
            Item(
                image: UIImage(systemName: "face.smiling"),
                tintColor: .systemBlue
            ),
            Item(
                image: UIImage(systemName: "pencil"),
                tintColor: .systemBlue
            ),
        ], toSection: .recommended)

        return snapshot
    }
}
