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

    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item>
    func makeLayout() -> UICollectionViewLayout
}
