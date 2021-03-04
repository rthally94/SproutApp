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
        
        snapshot.appendSections([.plantInfo])
        snapshot.appendItems([
            Item(text: strongPlant.name, secondaryText: strongPlant.type.commonName, plantIcon: strongPlant.icon)
        ], toSection: .plantInfo)
        
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
        UICollectionView.CellRegistration<CareInfoCell, Item> { _, _, _ in
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

class CareInfoCell: UICollectionViewCell {}

class PlantHeaderCell: UICollectionViewCell {
    lazy var plantIconView = PlantIconView()
    
    lazy var plantNameLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        return view
    }()
    
    lazy var plantTypeLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.preferredFont(forTextStyle: .headline)
        view.tintColor = view.tintColor.withAlphaComponent(0.7)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHiearchy()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureHiearchy() {
        plantIconView.translatesAutoresizingMaskIntoConstraints = false
        plantNameLabel.translatesAutoresizingMaskIntoConstraints = false
        plantTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(plantIconView)
        contentView.addSubview(plantNameLabel)
        contentView.addSubview(plantTypeLabel)
        
        NSLayoutConstraint.activate([
            plantIconView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            plantIconView.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor, multiplier: 0.5),
            plantIconView.heightAnchor.constraint(equalTo: plantIconView.widthAnchor),
            plantIconView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            
            plantNameLabel.topAnchor.constraint(equalToSystemSpacingBelow: plantIconView.bottomAnchor, multiplier: 2.0),
            plantNameLabel.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            plantNameLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.widthAnchor),
            
            plantTypeLabel.topAnchor.constraint(equalToSystemSpacingBelow: plantNameLabel.bottomAnchor, multiplier: 1.0),
            plantTypeLabel.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            plantTypeLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.widthAnchor),
            plantTypeLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }
}
