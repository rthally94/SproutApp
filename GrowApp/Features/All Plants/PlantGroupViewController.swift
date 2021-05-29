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
    typealias Item = PlantGroupViewModel.Item
    typealias Section = PlantGroupViewModel.Section
    typealias Snapshot = PlantGroupViewModel.Snapshot

    var viewModel: PlantGroupViewModel = PlantGroupViewModel()
    
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
        configureHiearchy()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.delegate = self
        dataSource = makeDataSource()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPlant))

        viewModel.snapshot
            .sink(receiveValue: { [weak self] snapshot in
                self?.dataSource.apply(snapshot)
            })
            .store(in: &cancellables)

        viewModel.$navigationTitle
            .assign(to: \.title, on: self)
            .store(in: &cancellables)

        viewModel.$presentedView
            .sink { view in
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

    func showPlantDetail(for plant: SproutPlant) {
        let vc = PlantDetailViewController()
        vc.persistentContainer = viewModel.persistentContainer
        vc.plant = plant
        navigationController?.pushViewController(vc, animated: true)
    }

    func showNewPlantEditor() {
        let vc = AddEditPlantCollectionViewController(storageProvider: AppDelegate.storageProvider)
        vc.delegate = self
        present(vc.wrappedInNavigationController(), animated: true)
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
        return UICollectionView.CellRegistration<CardCell, Item>() { cell, indexPath, item in
            cell.image = item.image
            cell.text = item.title
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
}

// MARK: - PlantEditorDelegate
extension PlantGroupViewController: AddEditPlantViewControllerDelegate {
    func plantEditor(_ editor: AddEditPlantViewController, didUpdatePlant plant: SproutPlant) {
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
