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
    // MARK: - Properties
    typealias Section = PlantsProvider.Section
    typealias Item = PlantsProvider.Item

    var persistentContainer: NSPersistentContainer = AppDelegate.persistentContainer
    private var plantsProvider: PlantsProvider?
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var cancellables = Set<AnyCancellable>()
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        cv.backgroundColor = .clear
        cv.delegate = self
        return cv
    }()
    
    // MARK: - View Life Cycle
    override func loadView() {
        super.loadView()
        configureHiearchy()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        plantsProvider = PlantsProvider(managedObjectContext: persistentContainer.viewContext)
        dataSource = makeDataSource()
        plantsProvider?.$snapshot
            .sink(receiveValue: { [weak self] snapshot in
                if let snapshot = snapshot {
                    self?.dataSource.apply(snapshot)
                }
            })
            .store(in: &cancellables)
        
        title = "Your Plants"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPlant))
    }


    func configureHiearchy() {
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    // MARK: - Actions
    @objc func addNewPlant() {
        let viewContext = persistentContainer.viewContext

        do {
            let newPlant = try GHPlant.createDefaultPlant(inContext: viewContext)
            let vc = PlantEditorControllerController()
            vc.plant = newPlant
            vc.persistentContainer = persistentContainer
            vc.delegate = self
            present(vc.wrappedInNavigationController(), animated: true)
            
        } catch {
            fatalError("Unable to create new plant with default template: \(error)")
        }
    }
}

// MARK: - UICollectionView Configuration
extension PlantGroupViewController {
    func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.65))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 16, leading: 8, bottom: 0, trailing: 8)
        section.interGroupSpacing = 16
        
        return UICollectionViewCompositionalLayout(section: section)
    }

    func makeCellRegistration() -> UICollectionView.CellRegistration<CardCell, Item> {
        return UICollectionView.CellRegistration<CardCell, Item>() {[weak self] cell, indexPath, item in
            guard let plant = self?.plantsProvider?.object(at: indexPath) else { return }
            cell.image = plant.icon?.image
            cell.text = plant.name
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

// MARK: - UICollectionViewDelegate
extension PlantGroupViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = plantsProvider?.object(at: indexPath)
        let vc = PlantDetailViewController()
        vc.persistentContainer = persistentContainer
        vc.plant = item
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - PlantEditorDelegate
extension PlantGroupViewController: PlantEditorDelegate {
    func plantEditor(_ editor: PlantEditorControllerController, didUpdatePlant plant: GHPlant) {
        persistentContainer.saveContextIfNeeded()
        plantsProvider?.reload()
    }

    func plantEditorDidCancel(_ editor: PlantEditorControllerController) {
        if let plant = editor.plant {
            persistentContainer.viewContext.delete(plant)
        }
    }
}
