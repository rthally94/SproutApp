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
    
    var model: GreenHouseAppModel
    let viewContext: NSManagedObjectContext
    let plantsProvider: PlantsProvider
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    var cancellables = Set<AnyCancellable>()
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        cv.backgroundColor = .clear
        cv.delegate = self
        return cv
    }()
    
    // MARK: - Initializers
    init(viewContext: NSManagedObjectContext, model: GreenHouseAppModel) {
        self.viewContext = viewContext
        self.plantsProvider = PlantsProvider(managedObjectContext: viewContext)
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPlant))
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
    
    @objc func addNewPlant() {
        let editingContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        editingContext.parent = viewContext
        
        // 1. Create a new plant in the model
        let newPlant = GHPlant(context: editingContext)
        let wateringTask = GHTask(context: editingContext)
        wateringTask.id = UUID()
        wateringTask.taskType = GHTaskType.wateringTaskType(context: editingContext)
        newPlant.addToTasks_(wateringTask)
        
        let vc = PlantEditorControllerController(plant: newPlant, viewContext: editingContext)
        vc.delegate = self
        present(vc.wrappedInNavigationController(), animated: true)
    }
}

extension PlantGroupViewController: PlantEditorDelegate {
    func plantEditor(_ editor: PlantEditorControllerController, didUpdatePlant plant: GHPlant) {
        do {
            try viewContext.save()
        } catch {
            viewContext.rollback()
        }
    }
}

extension PlantGroupViewController {
    func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .estimated(200))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 16, leading: 16, bottom: 0, trailing: 16)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension PlantGroupViewController {
    func makeCellRegistration() -> UICollectionView.CellRegistration<PlantCardCell, Item> {
        return UICollectionView.CellRegistration<PlantCardCell, Item>() {[weak self] cell, indexPath, item in
            guard let plant = self?.plantsProvider.object(at: indexPath) else { return }
            var config = cell.iconView.defaultConfiguration()
            config.image = plant.icon?.image
            cell.iconView.iconViewConfiguration = config
            
            cell.textLabel.text = plant.name
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
        let vc = PlantDetailViewController(plant: item, viewContext: viewContext)
        navigationController?.pushViewController(vc, animated: true)
    }
}
