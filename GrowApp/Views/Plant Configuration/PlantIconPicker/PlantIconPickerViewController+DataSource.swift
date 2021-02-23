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
            cell.icon = item.icon
        }
    }

    func configureDataSource() {
        let cellRegistration = makeCellRegistration()

        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        dataSource.apply(createDefaultSnapshot())
    }

    func createDefaultSnapshot() -> NSDiffableDataSourceSnapshot<Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        snapshot.appendSections([.currentImage, .recommended])
        snapshot.appendItems([
            Item(icon: plant!.icon)
        ], toSection: .currentImage)

        snapshot.appendItems([
            Item(
                icon: .symbol(name: "camera", foregroundColor: .systemBlue, backgroundColor: .secondarySystemGroupedBackground),
                onTap: {
                    self.showImagePicker(preferredType: .camera)
                }
            ),
            Item(
                icon: .symbol(name: "photo.on.rectangle", foregroundColor: .systemBlue, backgroundColor: .secondarySystemGroupedBackground),
                onTap: {
                    self.showImagePicker(preferredType: .photoLibrary)
                }
            ),
            Item(icon: .symbol(name: "face.smiling", foregroundColor: .systemBlue, backgroundColor: .secondarySystemGroupedBackground)),
            Item(icon: .symbol(name: "pencil", foregroundColor: .systemBlue, backgroundColor: .secondarySystemGroupedBackground)),
        ], toSection: .recommended)

        return snapshot
    }
}
