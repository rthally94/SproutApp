//
//  TaskIntervalEditorController.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/8/21.
//

import CoreData
import UIKit

class TaskEditorController: UIViewController {
    let viewContext: NSManagedObjectContext
    let task: GHTask
    
    private var collectionView: UICollectionView!
    
    init(task: GHTask, viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.task = viewContext.object(with: task.objectID) as! GHTask
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private enum Section: Hashable, CaseIterable {
        case header, type, interval, notes, actions
    }
    
    private struct Item: Hashable {
        let image: UIImage?
        let text: String?
        let secondaryText: String?
        let tintColor: UIColor?
        let action: (() -> Void)?
        
        init(image: UIImage?, text: String?, secondaryText: String? = nil, tintColor: UIColor? = nil, action: (() -> Void)? = nil) {
            self.image = image
            self.text = text
            self.secondaryText = secondaryText
            self.tintColor = tintColor
            self.action = action
        }
        
        static func == (lhs: TaskEditorController.Item, rhs: TaskEditorController.Item) -> Bool {
            return lhs.image == rhs.image
                && lhs.text == rhs.text
                && lhs.secondaryText == rhs.secondaryText
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(image)
            hasher.combine(text)
            hasher.combine(secondaryText)
        }
    }
}

extension TaskEditorController {
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func makeLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        
        // Header Row
        snapshot.appendItems([
            Item(image: task.category?.icon?.image, text: task.category?.name, tintColor: task.category?.icon?.color)
        ], toSection: .header)
        
        // Type Selection
        snapshot.appendItems([
        
        ], toSection: .type)
        
        return snapshot
    }
}
