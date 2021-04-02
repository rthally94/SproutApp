//
//  PlantGroupVIewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/27/21.
//

import Combine
import CoreData
import UIKit

class PlantGroupViewController: UIViewController {
    typealias Section = PlantsProvider.Section
    typealias Item = PlantsProvider.Item
    
    var model: GreenHouseAppModel
    let storageProvider: StorageProvider
    let plantsProvider: PlantsProvider
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    var cancellables = Set<AnyCancellable>()
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        cv.backgroundColor = .clear
        cv.delegate = self
        return cv
    }()
    
    init(storageProvider: StorageProvider, model: GreenHouseAppModel) {
        self.storageProvider = storageProvider
        self.plantsProvider = PlantsProvider(storageProvider: storageProvider)
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        configureHiearchy()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = makeDataSource()
        plantsProvider.$snapshot
            .sink(receiveValue: { [weak self] snapshot in
                if let snapshot = snapshot {
                    self?.dataSource.apply(snapshot)
                }
            })
            .store(in: &cancellables)
        
        title = "Your Plants"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showPlantConfiguration))
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
        let vc = PlantConfigurationViewController(storageProvider: storageProvider, model: model)
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
        return UICollectionView.CellRegistration<PlantCardCell, Item>() {[weak self] cell, indexPath, item in
            guard let plant = self?.plantsProvider.object(at: indexPath) else { return }
            var config = cell.iconView.defaultConfiguration()
            config.icon = plant.icon
            cell.iconView.iconViewConfiguration = config
            
            cell.textLabel.text = plant.name
            
            let taskCount = plant.tasks.count
            cell.secondaryTextLabel.text = "\(taskCount) tasks"
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
        let item = plantsProvider.object(at: indexPath)
        let vc = PlantDetailViewController(plant: item, storageProvider: storageProvider, model: model)
        navigationController?.pushViewController(vc, animated: true)
    }
}
