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
    typealias Item = PlantGroupViewModel.Item
    typealias Section = PlantGroupViewModel.Section
    typealias Snapshot = PlantGroupViewModel.Snapshot

    var viewModel: PlantGroupViewModel = PlantGroupViewModel()
    
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

        navigationController?.delegate = self
        dataSource = makeDataSource()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPlant))

        viewModel.snapshot
            .sink(receiveValue: { [weak self] snapshot in
                if let snapshot = snapshot {
                    self?.dataSource.apply(snapshot)
                }
            })
            .store(in: &cancellables)

        viewModel.$navigationTitle
            .assign(to: \.title, on: self)
            .store(in: &cancellables)

        viewModel.$presentedView
            .sink {[unowned self] view in
                switch view {
                case .newPlant:
                    self.showNewPlantEditor()
                case let .plantDetail(plant):
                    self.showPlantDetail(for: plant)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    func configureHiearchy() {
        view = collectionView
    }

    // MARK: - Actions
    @objc func addNewPlant() {
        viewModel.addNewPlant()
    }

    func showPlantDetail(for plant: SproutPlantMO) {
        let vc = PlantDetailViewController()
        vc.persistentContainer = viewModel.persistentContainer
        vc.plant = plant
        navigationController?.pushViewController(vc, animated: true)
    }

    func showNewPlantEditor() {
        let vc = AddEditPlantViewController(storageProvider: AppDelegate.storageProvider)
        vc.delegate = self
        present(vc.wrappedInNavigationController(), animated: true)
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
            guard let plant = self.viewModel.plant(withID: item) else { return }
            cell.image = plant.icon ?? UIImage.PlaceholderPlantImage
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
        viewModel.selectPlant(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            let editAction = UIAction(title: "Edit Plant", image: UIImage(systemName: "pencil")) { action in
                print("I should edit the plant")
            }

            let deleteAction = UIAction(title: "Delete Plant", image: UIImage(systemName: "trash.fill"), attributes: .destructive) { action in
                print("I should delete the plant")
            }

            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}

// MARK: - PlantEditorDelegate
extension PlantGroupViewController: AddEditPlantViewControllerDelegate {
    func plantEditor(_ editor: AddEditPlantViewController, didUpdatePlant plant: SproutPlantMO) {
        viewModel.showList()

        viewModel.persistentContainer.viewContext.refresh(plant, mergeChanges: true)
        viewModel.persistentContainer.saveContextIfNeeded()
    }

    func plantEditorDidCancel(_ editor: AddEditPlantViewController) {
        viewModel.showList()
    }
}

// MARK: - UINavigationControllerDelegate
extension PlantGroupViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController == self {
            viewModel.showList()
        }
    }
}
