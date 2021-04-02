//
//  TimelineViewController+DataSource.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/24/21.
//

import UIKit

extension TaskCalendarViewController {
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        let plantTaskCellRegistration = createPlantCellRegistration()
        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
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
        
        return dataSource
    }

    private func createPlantCellRegistration() -> UICollectionView.CellRegistration<TaskCalendarListCell, Item> {
        return UICollectionView.CellRegistration<TaskCalendarListCell, Item> {cell, indexPath, item in
//            guard let task = self?.taskCalendarProvider.object(at: indexPath) else { return }
            
//            if item.task.currentStatus() == .complete {
//                cell.accessories = [.checkmark()]
//            } else {
//                let actionHander: UIActionHandler = {[weak self] _ in
//                    guard let self = self else { return }
//                    let plant = item.plant
//                    let task = item.task
//
//                    plant.logCare(for: task)
//                    self.reloadView()
//                }
//                cell.accessories = [
//                    .todoAccessory(actionHandler: actionHander)
//                ]
//            }
//
//            cell.updateWith(task: item.task, plant: item.plant)
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
