//
//  PlantDetailViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/2/21.
//

import UIKit

class PlantDetailViewController: UIViewController {
    static let careDateFormatter = RelativeDateFormatter()
    var model: GrowAppModel
    var plant: Plant? {
        didSet {
            configureSubviews()
        }
    }
    
    init(model: GrowAppModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum Section: Hashable, CaseIterable {
        case plantInfo
        case summary
        case upNext
        case careInfo
        
        func headerTitle() -> String? {
            switch self {
            case .upNext:
                return "Up Next"
            case .careInfo:
                return "Care Info"
            default:
                return nil
            }
        }
        
        func headerSubtitle() -> String? {
            switch self {
            case .careInfo:
                return ""
            default:
                return nil
            }
        }
        
        func headerIcon() -> UIImage? {
            switch self {
            default:
                return nil
            }
        }
    }
    
    struct Item: Hashable {
        var id: UUID?
        var icon: Icon?
        var text: String?
        var secondaryText: String?
    }
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        view.backgroundColor = .systemGroupedBackground
        view.delegate = self
        return view
    }()
    
    lazy var dataSource: UICollectionViewDiffableDataSource<Section, Item> = makeDataSource()
    
    override func loadView() {
        super.loadView()
        
        configureHiearchy()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Plant Details"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPlant))
    }
    
    //MARK: Actions
    @objc private func editPlant() {
        guard let plant = plant else { return }
        let vc = PlantConfigurationViewController(plant: plant, model: model)
        present(vc.wrappedInNavigationController(), animated: true)
    }
}

extension PlantDetailViewController {
    func nextTaskDateStirng() -> String? {
        if let plant = plant, let nextTaskDate = plant.getDateOfNextTask() {
            return PlantDetailViewController.careDateFormatter.string(from: nextTaskDate)
        } else {
            return nil
        }
    }
}

extension PlantDetailViewController {
    func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let sectionKind = Section.allCases[sectionIndex]
            switch sectionKind {
            case .plantInfo:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0)
                return section
            case .summary:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(64))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 10, bottom: 20, trailing: 20)
                return section
            case .upNext, .careInfo:
                var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                config.headerMode = .supplementary
                
                let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
                return section
            }
        }
        
        return layout
    }
}

extension PlantDetailViewController {
    func makeSnapshot() -> NSDiffableDataSourceSnapshot<Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        guard let strongPlant = plant else { return snapshot }
        
        snapshot.appendSections(Section.allCases)
        
        // Plant Info Header
        snapshot.appendItems([
            Item(icon: strongPlant.icon, text: strongPlant.name, secondaryText: strongPlant.type.commonName)
        ], toSection: .plantInfo)
        
        // Plant Care Summary
        let tasksToday = plant?.todaysTasks()
        let lateTasks = plant?.lateTasks()
        
        let todayColor = tasksToday?.isEmpty ?? true ? UIColor.systemGreen.withAlphaComponent(0.5) : UIColor.systemGreen
        let lateColor = lateTasks?.isEmpty ?? true ? UIColor.systemYellow.withAlphaComponent(0.5) : UIColor.yellow
        
        snapshot.appendItems([
            Item(icon: .symbol(name: "calendar.badge.clock", tintColor: todayColor), text: "Today", secondaryText: "\(tasksToday?.count ?? 0) tasks"),
            Item(icon: .symbol(name: "exclamationmark.circle", tintColor: lateColor), text: "Late", secondaryText: "\(lateTasks?.count ?? 0) tasks")
        ], toSection: .summary)
        
        // Up Next
        let nextTasks: [Item] = strongPlant.nextTasks().map { task in
            let lastCareString: String
            if let lastCareDate = task.lastCareDate {
                lastCareString = "Last: " + PlantDetailViewController.careDateFormatter.string(from: lastCareDate)
            } else {
                lastCareString = "Last: Never"
            }
            return Item(id: task.id, icon: task.type.icon, text: task.type.description, secondaryText: lastCareString)
        }
        
        snapshot.appendItems(nextTasks, toSection: .upNext)
        
        // All Tasks
        let items: [Item] = strongPlant.tasks.map { task in
            return Item(id: task.id, icon: task.type.icon, text: task.type.description, secondaryText: task.interval.description)
        }
        
        snapshot.appendItems(items, toSection: .careInfo)
        return snapshot
    }
    
    func makeHeaderCellRegistration() -> UICollectionView.CellRegistration<IconHeaderCell, Item> {
        UICollectionView.CellRegistration<IconHeaderCell, Item> { cell, _, item in
            if let icon = item.icon {
                var config = cell.iconView.defaultConfiguration()
                config.icon = icon
                cell.iconView.iconViewConfiguration = config
            }
            
            cell.titleLabel.text = item.text
            cell.subtitleLabel.text = item.secondaryText
            cell.backgroundColor = .systemGroupedBackground
        }
    }
    
    func makeSummaryCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, _, item in
            var config = UIListContentConfiguration.statisticCell()
            
            config.image = item.icon?.image
            config.text = item.text
            config.secondaryText = item.secondaryText
            
            config.imageProperties.tintColor = item.icon?.tintColor
            config.secondaryTextProperties.color = item.icon?.tintColor ?? config.textProperties.color
            
            cell.contentConfiguration = config
            
            cell.contentView.backgroundColor = .secondarySystemGroupedBackground
            cell.layer.cornerRadius = 10
            cell.clipsToBounds = true
        }
    }
    
    func makeUpNextCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, _, item in
            var config = UIListContentConfiguration.subtitleCell()
            
            config.image = item.icon?.image
            config.imageProperties.tintColor = item.icon?.tintColor
            
            config.text = item.text
            config.secondaryText = item.secondaryText
            
            cell.contentConfiguration = config
            
            cell.accessories = [ .todoAccessory() ]
        }
    }
    
    func makeCareInfoCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, _, item in
            var config = UIListContentConfiguration.subtitleCell()
            
            if case let .symbol(symbolName, tintColor) = item.icon {
                config.image = UIImage(systemName: symbolName)
                config.imageProperties.tintColor = tintColor
            } else if case let .image(image) = item.icon {
                config.image = image
            }
            
            config.text = item.text
            config.secondaryText = item.secondaryText
            
            cell.contentConfiguration = config
            cell.accessories = [
                .disclosureIndicator()
            ]
        }
    }
    
    func makeInsetGroupedSectionHeaderRegistration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { [unowned self] cell, elementKind, indexPath in
            guard elementKind == UICollectionView.elementKindSectionHeader else { return }
            var config = UIListContentConfiguration.largeGroupedHeader()
            
            let section = Section.allCases[indexPath.section]
            config.text = section.headerTitle()?.capitalized
            if case .upNext = section {
                config.secondaryText = self.nextTaskDateStirng()
            }
            
            cell.contentConfiguration = config
        }
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        let headerCellRegistration = makeHeaderCellRegistration()
        let summaryCellRegistration = makeSummaryCellRegistration()
        let upNextCellRegistration = makeUpNextCellRegistration()
        let careInfoCellRegistration = makeCareInfoCellRegistration()
        
        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            let sectionKind = Section.allCases[indexPath.section]
            switch sectionKind {
            case .plantInfo:
                return collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration, for: indexPath, item: item)
            case .summary:
                return collectionView.dequeueConfiguredReusableCell(using: summaryCellRegistration, for: indexPath, item: item)
            case .upNext:
                return collectionView.dequeueConfiguredReusableCell(using: upNextCellRegistration, for: indexPath, item: item)
            case .careInfo:
                return collectionView.dequeueConfiguredReusableCell(using: careInfoCellRegistration, for: indexPath, item: item)
            }
        }
        
        let defaultHeaderRegistration = makeInsetGroupedSectionHeaderRegistration()
        dataSource.supplementaryViewProvider = { collectionView, _, indexPath in
            let sectionKind = Section.allCases[indexPath.section]
            switch sectionKind {
            case .upNext, .careInfo:
                return collectionView.dequeueConfiguredReusableSupplementary(using: defaultHeaderRegistration, for: indexPath)
            default:
                return nil
            }
        }
        
        return dataSource
    }
}

extension PlantDetailViewController {
    func configureHiearchy() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.pinToBoundsOf(view)
    }
    
    func configureSubviews() {
        guard plant != nil else { return }
        
        let snapshot = makeSnapshot()
        dataSource.apply(snapshot)
    }
}

extension PlantDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let sectionKind = Section.allCases[indexPath.section]
        switch sectionKind {
        case .careInfo:
            return true
        default:
             return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionKind = Section.allCases[indexPath.section]
        
        if sectionKind == .careInfo {
            let vc = CareDetailViewController(nibName: nil, bundle: nil)
            vc.plant = plant
            vc.selectedTaskID = dataSource.itemIdentifier(for: indexPath)?.id
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
