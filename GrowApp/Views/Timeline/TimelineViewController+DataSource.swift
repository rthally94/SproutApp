//
//  TimelineViewController+DataSource.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/24/21.
//

import UIKit

extension TimelineViewController {
    func configureDataSource() {
        let plantTaskCellRegistration = createPlantCellRegistration()
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            // TODO:- dequeue configured cells
            return collectionView.dequeueConfiguredReusableCell(using: plantTaskCellRegistration, for: indexPath, item: item)
        }

        // TODO:- Supplemetary View Provider (Headers)
        let taskHeader = createHeaderRegistration()
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            switch elementKind {
                case UICollectionView.elementKindSectionHeader:
                    return collectionView.dequeueConfiguredReusableSupplementary(using: taskHeader, for: indexPath)
                default:
                    return nil
            }
        }
    }

    func createSnapshot(for plants: [TaskType: [Plant]]) -> NSDiffableDataSourceSnapshot<Section, Item> {
        // Transform [Task: [Plant]] to [Section: [Item]]
        let data: [Section: [Item]] = plants.reduce(into: [Section: [Item]]() ) { dict, item in
            let (taskType, plants) = item
            let section = Section(careIcon: taskType.icon, taskName: taskType.description)
            let items: [Item] = plants.compactMap { plant in
                // TODO: - Change parameter from nextCareDate to lastCareDate
                guard let task = plant.tasks.first(where: { $0.type == taskType }) else { return nil }
                let lastCareDateString = task.interval.description

                // TODO: - Add missing parameter: isComplete
                let isComplete = Calendar.current.compare(task.nextCareDate, to: selectedDate, toGranularity: .day) == .orderedAscending
                return Item(id: UUID(), plantName: plant.name, lastCareDate: lastCareDateString, plantIcon: plant.icon, isComplete: isComplete)
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
            cell.plantIconView.icon = item.plantIcon
            cell.titleLabel.text = item.plantName
            cell.subtitleLabel.text = item.lastCareDate
            cell.todoButton.setImage(item.isComplete ? cell.completeSymbol : cell.incompleteSymbol, for: .normal)
        }
    }

    private func createHeaderRegistration() -> UICollectionView.SupplementaryRegistration<CollectionViewHeader> {
        return UICollectionView.SupplementaryRegistration<CollectionViewHeader>(elementKind: UICollectionView.elementKindSectionHeader) { cell, elementKind, indexPath in
            // TODO:- configure cell
            let sortedKeys = self.data.keys.sorted(by: { $0.description < $1.description })
            if indexPath.section < sortedKeys.endIndex {
                let task = sortedKeys[indexPath.section]
                cell.tintColor = task.accentColor
                cell.imageView.image = task.icon
                cell.textLabel.text = task.description
            }
        }
    }
}
