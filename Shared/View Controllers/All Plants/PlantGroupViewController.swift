//
//  PlantGroupVIewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/27/21.
//

import Combine
import CoreData
import UIKit
import SproutKit

class PlantGroupViewController: UIViewController {
    // MARK: - Properties
    typealias Item = PlantsProvider.Item
    typealias Section = PlantsProvider.Section
    typealias Snapshot = PlantGroupViewModel.Snapshot

    weak var coordinator: PlantsCoordinator?

    var persistentContainer: NSPersistentContainer!
    var plantsProvider: PlantsProvider!
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var cancellables = Set<AnyCancellable>()
    
    lazy var collectionView: UICollectionView = { [unowned self] in
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        cv.backgroundColor = .systemGroupedBackground
        cv.delegate = self
        return cv
    }()
    
    // MARK: - View Life Cycle
    override func loadView() {
        configureHiearchy()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = makeDataSource()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPlantButtonPressed))
        title = "Your Plants"

        plantsProvider.$snapshot
            .sink(receiveValue: { [weak self] snapshot in
                if let snapshot = snapshot {
                    self?.dataSource.apply(snapshot)
                }
            })
            .store(in: &cancellables)
    }

    func configureHiearchy() {
        view = collectionView
    }

    // MARK: - Actions
    @objc func addPlantButtonPressed() {
        showNewPlantEditor()
    }

    private func showPlantDetail(for plant: SproutPlantMO) {
        coordinator?.showDetail(plant: plant)
    }

    private func showNewPlantEditor() {
        coordinator?.addNewPlant()
    }

    private func showPlantEditor(for plant: SproutPlantMO) {
        coordinator?.edit(plant: plant)
    }
}

// MARK: - UICollectionView Configuration
extension PlantGroupViewController {
    func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.6))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(16)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 16, leading: 16, bottom: 0, trailing: 16)
        section.interGroupSpacing = 16
        
        return UICollectionViewCompositionalLayout(section: section)
    }

    func makeCellRegistration() -> UICollectionView.CellRegistration<SproutCardCell, Item> {
        return UICollectionView.CellRegistration<SproutCardCell, Item>() {[unowned self] cell, indexPath, item in
            guard let plant = plantsProvider.object(withID: item) else { return }
            cell.image = plant.getImage() ?? UIImage.PlaceholderPlantImage
            cell.text = plant.primaryDisplayName
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
        let plant = plantsProvider.object(at: indexPath)
        coordinator?.showDetail(plant: plant)
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let plant = plantsProvider.object(at: indexPath)

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) {[weak self] suggestedActions in
            let editAction = UIAction(title: "Edit Plant", image: UIImage(systemName: "pencil")) { action in
                self?.coordinator?.edit(plant: plant)
            }

            let deleteAction = UIAction(title: "Delete Plant", image: UIImage(systemName: "trash.fill"), attributes: .destructive) { action in
                self?.coordinator?.delete(plant: plant)
            }

            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}
