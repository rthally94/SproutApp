//
//  CareDetailViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/4/21.
//

import UIKit

class CareDetailViewController: UIViewController {
    var plant: Plant?
    
    enum Section: Hashable, CaseIterable {
        case header
    }
    
    struct Item: Hashable {
        var image: UIImage?
        var text: String?
        var secondaryText: String?
    }
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        return view
    }()
    
    lazy var dataSource = makeDataSource()
    
    override func loadView() {
        super.loadView()
        
        configureHiearchy()
    }
}

extension CareDetailViewController {
    func makeLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    func configureHiearchy() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.pinToBoundsOf(view)
    }
}

extension CareDetailViewController {
    func makeSnapshot() -> NSDiffableDataSourceSnapshot<Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems([], toSection: .header)
        
        return snapshot
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        let cellRegistration  = makeCellRegistration()
        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        return dataSource
    }
    
    func makeCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Item>() { cell, indexPath, item in
            var config = cell.defaultContentConfiguration()
            config.text = item.text
            config.secondaryText = item.secondaryText
            config.image = item.image
        }
    }
}
