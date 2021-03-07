//
//  PlantGroupVIewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/27/21.
//

import UIKit

class PlantGroupViewController: UIViewController {
    var model: GrowAppModel?
    
    convenience init(model: GrowAppModel) {
        self.init(nibName: nil, bundle: nil)
        self.model = model
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum Section: Hashable {
        case plants
    }
    
    struct Item: Hashable {
        let id: UUID
        let icon: Icon
        let title: String
        let subtitle: String?
    }
    
    lazy var dataSource = makeDataSource()
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        cv.backgroundColor = .clear
        cv.delegate = self
        return cv
    }()
    
    override func loadView() {
        super.loadView()
        
        configureHiearchy()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(showPlantConfiguration))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let model = model {
            let plants = model.getPlants()
            
            var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
            snapshot.appendSections([.plants])
            
            let items = plants.map { plant in
                Item(id: plant.id, icon: plant.icon, title: plant.name, subtitle: "\(plant.tasks.count) tasks")
            }
            snapshot.appendItems(items, toSection: .plants)
            
            dataSource.apply(snapshot)
        }
    }
    
    func configureHiearchy() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func showPlantConfiguration() {
        let vc = PlantConfigurationViewController()
        
        present(vc.wrappedInNavigationController(), animated: true)
    }
}

extension PlantGroupViewController {
    func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension PlantGroupViewController {
    func makeCellRegistration() -> UICollectionView.CellRegistration<PlantCardCell, Item> {
        return UICollectionView.CellRegistration<PlantCardCell, Item>() { cell, indexPath, item in
            
            var config = cell.iconView.defaultConfiguration()
            config.icon = item.icon
            cell.iconView.iconViewConfiguration = config
            
            cell.textLabel.text = item.title
            cell.secondaryTextLabel.text = item.subtitle
        }
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        let cellRegistration = makeCellRegistration()
            
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        return dataSource
    }
}

extension PlantGroupViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = dataSource.itemIdentifier(for: indexPath), let plant = model?.getPlant(with: item.id) {
            let vc = PlantDetailViewController()
            vc.plant = plant
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
