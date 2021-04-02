//
//  PlantDetailViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/2/21.
//

import UIKit

class PlantDetailViewController: UIViewController {
    static let dateComponentsFormatter: DateComponentsFormatter = {
       let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.month, .weekOfMonth, .day]
        formatter.maximumUnitCount = 1
        formatter.formattingContext = .beginningOfSentence
        formatter.unitsStyle = .full
        return formatter
    }()
    static let careDateFormatter = RelativeDateFormatter()
    
    var storageProvider: StorageProvider
    
    var plant: GHPlant
    
    init(plant: GHPlant, storageProvider: StorageProvider) {
        self.plant = plant
        self.storageProvider = storageProvider
        
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
        let icon: GHIcon?
        let image: UIImage?
        let tintColor: UIColor?
        let text: String?
        let secondaryText: String?
        let isComplete: Bool
        
        init(image: UIImage?, tintColor: UIColor?, text: String?, secondaryText: String?) {
            self.icon = nil
            self.image = image
            self.tintColor = tintColor
            self.text = text
            self.secondaryText = secondaryText
            self.isComplete = false
        }
        
        init(icon: GHIcon?, text: String?, secondaryText: String?, isComplete: Bool = false) {
            self.icon = icon
            self.image = nil
            self.tintColor = nil
            self.text = text
            self.secondaryText = secondaryText
            self.isComplete = isComplete
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        view.backgroundColor = .systemGroupedBackground
        view.delegate = self
        return view
    }()
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    override func loadView() {
        super.loadView()
        
        configureHiearchy()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = makeDataSource()
        reloadUI()
        
        title = "Plant Details"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPlant))
    }
    
    //MARK: Actions
    @objc private func editPlant() {
        let vc = PlantConfigurationViewController(plant: plant, storageProvider: storageProvider)
//        vc.onSave = configureSubviews
        
        present(vc.wrappedInNavigationController(), animated: true)
    }
}

extension PlantDetailViewController {
    func nextTaskDateString() -> String? {
        let nextTasks: [(task: GHTask, date: Date)] = plant.tasks.compactMap { task in
            if let nextDate = task.nextCareDate(after: Calendar.current.startOfDay(for: Date())) {
                return (task, nextDate)
            } else {
                return nil
            }
        }
        
        if let nextTask = nextTasks.min(by: { $0.date < $1.date }) {
            return PlantDetailViewController.careDateFormatter.string(from: nextTask.date)
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
        snapshot.appendSections(Section.allCases)
        
        // Plant Info Header
        snapshot.appendItems([
            Item(icon: plant.icon, text: plant.name, secondaryText: plant.type)
        ], toSection: .plantInfo)
        
        // Plant Care Summary
        let tasksToday: Set<GHTask> = plant.tasks.filter { task in
            task.isDateInInterval(Date())
        }
        let lateTasks: Set<GHTask> = plant.tasks.filter { task in
            task.isLate()
        }
        
        let todayColor = tasksToday.isEmpty ? UIColor.systemGreen.withAlphaComponent(0.5) : UIColor.systemGreen
        let lateColor = lateTasks.isEmpty ? UIColor.systemYellow.withAlphaComponent(0.5) : UIColor.yellow
        
        snapshot.appendItems([
            Item(image: UIImage(systemName: "calendar.badge.clock"), tintColor: todayColor, text: "Today", secondaryText: "\(tasksToday.count) tasks"),
            Item(image: UIImage(systemName: "exclamationmark.circle"), tintColor: lateColor, text: "Late", secondaryText: "\(lateTasks.count) tasks")
        ], toSection: .summary)
        
        // Up Next
        let next = lateTasks.union(tasksToday)
        let nextTasks: [Item] = next.map { task -> Item in
            let lastCareString: String
            if task.isLate() {
                guard let lastDate = task.lastCareDate, let expectedDate = task.nextCareDate(after: lastDate) else { fatalError("Unable to calculate days late but task was flagged as late.")}
                let daysLateComponents = Calendar.current.dateComponents([.day, .month], from: expectedDate, to: Calendar.current.startOfDay(for: Date()))
                lastCareString = "\(PlantDetailViewController.dateComponentsFormatter.string(from: daysLateComponents) ?? "Not") late"
            } else {
                lastCareString = ""
            }
            return Item(icon: task.category?.icon, text: task.category?.name, secondaryText: lastCareString)
        }
        
        snapshot.appendItems(nextTasks, toSection: .upNext)
        
        // All Tasks
        let items: [Item] = plant.tasks.compactMap { task in
            return Item(icon: task.category?.icon, text: task.category?.name, secondaryText: nil)
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
            
            config.image = item.image
            config.text = item.text
            config.secondaryText = item.secondaryText
            
            config.imageProperties.tintColor = item.tintColor
            config.secondaryTextProperties.color = item.tintColor ?? config.textProperties.color
            
            cell.contentConfiguration = config
            
            cell.contentView.backgroundColor = .secondarySystemGroupedBackground
            cell.layer.cornerRadius = 10
            cell.clipsToBounds = true
        }
    }
    
    func makeUpNextCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Item> {cell, _, item in
            var config = UIListContentConfiguration.subtitleCell()
            
            config.image = item.icon?.uiimage
            config.imageProperties.tintColor = item.icon?.uicolor
            
            config.text = item.text
            config.secondaryText = item.secondaryText
            
            cell.contentConfiguration = config
            
//            if let task = self?.plant?.tasks.first(where: {$0.id == item.task?.id}), task.currentStatus() == .complete {
//                cell.accessories = [ .checkmark() ]
//            } else {
//                let actionHandler: UIActionHandler = {[weak self] _ in
//                    guard let self = self, let task = item.task else { return }
//                    self.plant?.logCare(for: task)
//                    self.configureSubviews()
//                }
//                cell.accessories = [ .todoAccessory(actionHandler: actionHandler) ]
//            }
        }
    }
    
    func makeCareInfoCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, _, item in
            var config = UIListContentConfiguration.subtitleCell()
            
            config.image = item.image
            config.imageProperties.tintColor = item.tintColor
            
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
                config.secondaryText = self.nextTaskDateString()
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
    
    func reloadUI() {
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
//        let sectionKind = Section.allCases[indexPath.section]
        
//        if sectionKind == .careInfo {
//            let vc = CareDetailViewController(nibName: nil, bundle: nil)
//            vc.plant = plant
//            vc.selectedTask = dataSource.itemIdentifier(for: indexPath)?.task
//
//            navigationController?.pushViewController(vc, animated: true)
//        }
    }
}
