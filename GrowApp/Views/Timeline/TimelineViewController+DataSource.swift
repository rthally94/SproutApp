//
//  TimelineViewController+DataSource.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/24/21.
//

import UIKit

extension TimelineViewController {
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            // TODO:- dequeue configured cells
            return nil
        }

        // TODO:- Supplemetary View Provider (Headers)
    }

    func createSnapshot(for plants: [Task: [Plant]]) -> NSDiffableDataSourceSnapshot<Section, Item> {
        // Transform [Task: [Plant]] to [Section: [Item]]
        let data: [Section: [Item]] = plants.reduce(into: [Section: [Item]]() ) { dict, item in
            let (task, plants) = item
            let section = Section(careIcon: task.iconImage, taskName: task.name)
            let items = plants.map { plant in
                // TODO: - Add missing parameter: lastCareDate
                // TODO: - Add missing parameter: isComplete
                Item(plantName: plant.name, lastCareDate: nil, plantIcon: plant.icon, isComplete: false)
            }

            dict[section, default: []].append(contentsOf: items)
        }

        // Create the snapshot
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        // Apply the sections
        let sections = data.keys.sorted(by: { $0.taskName < $1.taskName })
        snapshot.appendSections(sections)

        // Apply the plants to each section
        data.forEach { (section, items) in
            snapshot.appendItems(items, toSection: section)
        }

        return snapshot
    }

    private func createPlantCellRegistration() -> UICollectionView.CellRegistration<TimelineCell, Item> {
        return UICollectionView.CellRegistration<TimelineCell, Item> { cell, indexPath, item in
            // TODO:- Configure cell
        }
    }

//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        plantsNeedingCare.count
//    }



//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimelineCell.reuseIdentifier, for: indexPath) as? TimelineCell else { fatalError("Unable to dequeu Timeline Cell") }
//
//        if indexPath.item == 0 {
//            cell.imageView.image = UIImage(systemName: "drop.fill")
//        }
//
//        let plant = plantsNeedingCare[indexPath.item]
//
//        cell.titleLabel.text = plant.name
//        cell.subtitleLabel.text = TimelineViewController.dateFormatter.string(from: Date())
//        cell.cellBackground.backgroundColor = .systemGray6
//
//        return cell
//    }
}
