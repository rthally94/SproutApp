//
//  PlantDetailViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/2/21.
//

import UIKit

class PlantDetailViewController: UIViewController {
    var plant: Plant? {
        didSet {
            configureSubviews()
        }
    }
    
    enum Section: Hashable, CaseIterable {
        case plantInfo
        case careInfo
        
        func headerTitle() -> String? {
            switch self {
                default: return nil
            }
        }
        
        func headerIcon() -> UIImage? {
            switch self {
                default:
                    return nil
            }
        }
    }
    
    struct Item: Hashable {
        var image: UIImage?
        var text: String?
        var secondaryText: String?
        var plantIcon: PlantIcon?
    }
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        view.backgroundColor = .systemBackground
        return view
    }()
    
    lazy var dataSource: UICollectionViewDiffableDataSource<Section, Item> = makeDataSource()
    
    override func loadView() {
        super.loadView()
        
        configureHiearchy()
    }
}

extension PlantDetailViewController {
    func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let sectionKind = Section.allCases[sectionIndex]
            switch sectionKind {
                case .plantInfo:
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    
                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                    
                    let section = NSCollectionLayoutSection(group: group)
                    return section
                case .careInfo:
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 2), heightDimension: .fractionalHeight(1.0))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                    
                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                    let section = NSCollectionLayoutSection(group: group)
                    return section
            }
        }
        
        return layout
    }
}

extension PlantDetailViewController {
    func makeSnapshot() -> NSDiffableDataSourceSnapshot<Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        guard let strongPlant = plant else { return snapshot }
        
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems([
            Item(text: strongPlant.name, secondaryText: strongPlant.type.commonName, plantIcon: strongPlant.icon)
        ], toSection: .plantInfo)
        
// TODO: Link to attributes of the plant
        snapshot.appendItems([
            Item(image: UIImage(systemName: "drop"), text: "Watering", secondaryText: "Top to Bottom"),
            Item(image: UIImage(systemName: "cloud.sun"), text: "Light", secondaryText: "Partial Shade"),
            Item(image: UIImage(systemName: "thermometer"), text: "Temperature", secondaryText: "10° - 17°"),
            Item(image: UIImage(systemName: "drop"), text: "Humidity", secondaryText: "60%"),
        ], toSection: .careInfo)
        return snapshot
    }
    
    func makeHeaderCellRegistration() -> UICollectionView.CellRegistration<PlantHeaderCell, Item> {
        UICollectionView.CellRegistration<PlantHeaderCell, Item> { cell, _, item in
            if let icon = item.plantIcon {
                cell.plantIconView.setIcon(icon)
            }
            
            cell.plantNameLabel.text = item.text
            cell.plantTypeLabel.text = item.secondaryText
        }
    }
    
    func makeCareInfoCellRegistration() -> UICollectionView.CellRegistration<CareInfoCell, Item> {
        UICollectionView.CellRegistration<CareInfoCell, Item> { cell, _, item in
            cell.careTypeIconView.image = item.image
            cell.careTypeLabel.text = item.text
            cell.careDetailLabel.text = item.secondaryText
        }
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        let headerCellRegistration = makeHeaderCellRegistration()
        let careInfoCellRegistration = makeCareInfoCellRegistration()
        
        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            let sectionKind = Section.allCases[indexPath.section]
            switch sectionKind {
                case .plantInfo:
                    return collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration, for: indexPath, item: item)
                case .careInfo:
                    return collectionView.dequeueConfiguredReusableCell(using: careInfoCellRegistration, for: indexPath, item: item)
            }
        }
        
        return dataSource
    }
}

extension PlantDetailViewController {
    func configureHiearchy() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.pinToBoundsOf(view)
    }
    
    func configureSubviews() {
        guard plant != nil else { return }
        
        let snapshot = makeSnapshot()
        dataSource.apply(snapshot)
    }
}
