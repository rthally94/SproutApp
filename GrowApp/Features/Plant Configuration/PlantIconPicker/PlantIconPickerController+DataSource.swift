//
//  PlantIconPickerViewController+DataSource.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/23/21.
//

import UIKit

extension PlantIconPickerController {
    func makeCellRegistration() -> UICollectionView.CellRegistration<IconCell, Item> {
        return UICollectionView.CellRegistration<IconCell, Item>() { cell, indexPath, item in
            var config = cell.defaultConfigurtion()
            config.image = item.image
            config.tintColor = item.tintColor
            cell.contentConfiguration = config
        }
    }
    
    func configureDataSource() {
        let cellRegistration = makeCellRegistration()
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        dataSource.apply(makeSnapshot())
    }
    
    func makeSnapshot() -> NSDiffableDataSourceSnapshot<Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        snapshot.appendSections([.currentImage, .recommended])
        snapshot.appendItems([
            Item(icon: icon)
        ], toSection: .currentImage)
        
        snapshot.appendItems([
            Item(
                image: UIImage(systemName: "camera"),
                tintColor: .systemBlue
            ) {
                self.showImagePicker(preferredType: .camera)
            },
            Item(
                image: UIImage(systemName: "photo.on.rectangle"),
                tintColor: .systemBlue
            ) {
                self.showImagePicker(preferredType: .photoLibrary)
            },
            Item(
                image: UIImage(systemName: "face.smiling"),
                tintColor: .systemBlue
            ) {
                print("🙈")
            },
            Item(
                image: UIImage(systemName: "pencil"),
                tintColor: .systemBlue
            ) {
                print("🙉")
            },
        ], toSection: .recommended)
        
        return snapshot
    }
}
