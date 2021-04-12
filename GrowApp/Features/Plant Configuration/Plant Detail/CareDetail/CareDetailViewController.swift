//
//  CareDetailViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/4/21.
//

import UIKit

class CareDetailViewController: UIViewController {
    static let dateFormatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var plant: Plant? {
        didSet {
            applySnapshotIfAble()
        }
    }
    
    var selectedTask: GHTask? {
        didSet {
            applySnapshotIfAble()
        }
    }
    
    enum Section: Hashable, CaseIterable {
        case header
        case schedule
    }
    
    struct Item: Hashable {
        var icon: GHIcon?
        var image: UIImage?
        var tintColor: UIColor?
        
        var text: String?
        var secondaryText: String?
        
        init(icon: GHIcon?, text: String?, secondaryText: String?) {
            self.icon = icon
            self.image = nil
            self.tintColor = nil
            self.text = text
            self.secondaryText = secondaryText
        }
        
        init(image: UIImage?, tintColor: UIColor?, text: String?, secondaryText: String?) {
            self.icon = nil
            self.image = image
            self.tintColor = tintColor
            self.text = text
            self.secondaryText = secondaryText
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        view.backgroundColor = .systemBackground
        return view
    }()
    
    lazy var dataSource = makeDataSource()
    
    override func loadView() {
        super.loadView()
        
        configureHiearchy()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Care Details"
    }
}

extension CareDetailViewController {
    func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let sectionKind = Section.allCases[sectionIndex]
            
            switch sectionKind {
            case .header:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                return section
            default:
                let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            }
        }
    
        return layout
    }
    
    func configureHiearchy() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.pinToBoundsOf(view)
    }
}

extension CareDetailViewController {
    func applySnapshotIfAble() {
        guard plant != nil && selectedTask != nil else { return }
        let snapshot = makeSnapshot()
        dataSource.apply(snapshot)
    }
    
    func makeSnapshot() -> NSDiffableDataSourceSnapshot<Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        if let selectedTask = selectedTask {
            snapshot.appendSections(Section.allCases)
            snapshot.appendItems([
                Item(icon: selectedTask.taskType?.icon, text: selectedTask.taskType?.description, secondaryText: selectedTask.interval?.description)
            ], toSection: .header)
        
            let image = Int(selectedTask.interval?.type ?? 0) == GHTaskIntervalType.none.rawValue ? UIImage(systemName: "bell.slash") : UIImage(systemName: "bell")
            let item = Item(image: image, tintColor: .systemBlue, text: nil, secondaryText: "Starting on \(CareDetailViewController.dateFormatter.string(from: selectedTask.interval?.startDate ?? Date()))")
            
            snapshot.appendItems([
                item
            ], toSection: .schedule)
        }
        
        return snapshot
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        let cellRegistration  = makeCellRegistration()
        let headerRegistration = makeHeaderCellRegistration()
        
        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            let sectionKind = Section.allCases[indexPath.section]
            switch sectionKind {
            case .header:
                return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: item)
            case .schedule:
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }
        }
        
        return dataSource
    }
    
    func makeHeaderCellRegistration() -> UICollectionView.CellRegistration<IconHeaderCell, Item> {
        UICollectionView.CellRegistration<IconHeaderCell, Item>() { cell, indexPath, item in
            if let icon = item.icon {
                var config = cell.iconView.defaultConfiguration()
                config.image = icon.image
                config.tintColor = icon.color
                cell.iconView.iconViewConfiguration = config
            }
            
            cell.titleLabel.text = item.text
            cell.subtitleLabel.text = item.secondaryText
        }
    }
    
    func makeCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Item>() { cell, indexPath, item in
            var config = cell.defaultContentConfiguration()
            config.text = item.text
            config.secondaryText = item.secondaryText
            config.image = item.image
            cell.contentConfiguration = config
        }
    }
}