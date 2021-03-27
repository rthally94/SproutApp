//
//  TimelineViewController+DataSource.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/24/21.
//

import UIKit

extension TaskCalendarViewController {
    func configureDataSource() {
        let plantTaskCellRegistration = createPlantCellRegistration()
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: plantTaskCellRegistration, for: indexPath, item: item)
        }

        // TODO: - Supplemetary View Provider (Headers)
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
        let data: [Section: [Item]] = plants.reduce(into: [Section: [Item]]()) { dict, item in
            let (taskType, plants) = item
            let section = Section(taskType: taskType)
            let items: [Item] = plants.compactMap { plant in
                guard let task = plant.tasks.first(where: { $0.type == taskType }) else { return nil }
                return Item(plant: plant, task: task)
            }

            dict[section, default: []].append(contentsOf: items)
        }

        // Create the snapshot
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        // Apply the sections
        let sections = data.keys.sorted(by: { $0.taskType.description < $1.taskType.description })
        snapshot.appendSections(sections)

        // Apply the plants to each section
        data.forEach { section, items in
            snapshot.appendItems(items, toSection: section)
        }

        return snapshot
    }

    private func createPlantCellRegistration() -> UICollectionView.CellRegistration<TaskCalendarListCell, Item> {
        return UICollectionView.CellRegistration<TaskCalendarListCell, Item> { cell, _, item in
            cell.accessories = [
                .todoAccessory()
            ]
            cell.updateWith(task: item.task, plant: item.plant)
        }
    }

    private func createHeaderRegistration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { cell, _, indexPath in
            // TODO: - configure cell
            let sortedKeys = self.data.keys.sorted(by: { $0.description < $1.description })
            if indexPath.section < sortedKeys.endIndex {
                let task = sortedKeys[indexPath.section]
                var config = UIListContentConfiguration.largeGroupedHeader()
                config.textProperties.color = task.accentColor ?? .label
                config.imageProperties.tintColor = task.accentColor

                if case let .symbol(symbolName, _) = task.icon {
                    config.image = UIImage(systemName: symbolName)
                } else if case let .image(image) = task.icon {
                    config.image = image
                }

                config.text = task.description
                
                cell.contentConfiguration = config
            }
        }
    }
}
