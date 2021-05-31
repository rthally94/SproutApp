//
//  StaticCollection.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/27/21.
//

import UIKit

protocol StaticCollection: UIViewController {
    associatedtype Section: Hashable
    associatedtype Item: Hashable

    var collectionView: UICollectionView { get set }
    var dataSource: UICollectionViewDiffableDataSource<Section, Item> { get set }

    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item>
    func makeLayout() -> UICollectionViewLayout
}
