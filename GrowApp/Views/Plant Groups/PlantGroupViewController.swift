//
//  PlantGroupVIewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/27/21.
//

import UIKit

class PlantGroupViewController: UIViewController {
    enum Section: Hashable {
        case plants
    }
    
    struct Item: Hashable {
        let image: UIImage
        let title: String
        let subtitle: String?
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        
        return cv
    }()
}

extension PlantGroupViewController {
    func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension PlantGroupViewController {
    func makeCellRegistration() -> UICollectionView.CellRegistration<PlantCardCell, Item> {
        return UICollectionView.CellRegistration<PlantCardCell, Item>() { cell, indexPath, item in
            cell.imageView.image = item.image
            cell.textLabel.text = item.title
            cell.secondaryTextLabel.text = item.subtitle
        }
    }
    
    func configureDataSource() {
        let cellRegistration = makeCellRegistration()
            
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
}
