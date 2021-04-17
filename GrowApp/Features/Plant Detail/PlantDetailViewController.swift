//
//  PlantDetailViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/2/21.
//

import CoreData
import UIKit

class PlantDetailViewController: UIViewController {
    // MARK: - Properties
    let dateComponentsFormatter = Utility.dateComponentsFormatter
    let careDateFormatter = Utility.relativeDateFormatter
    
    let viewContext: NSManagedObjectContext
    
    var plant: GHPlant
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    init(plant: GHPlant, viewContext: NSManagedObjectContext) {
        self.plant = viewContext.object(with: plant.objectID) as! GHPlant
        self.viewContext = viewContext
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum Section: Hashable, CaseIterable {
        case plantIcon, plantHeader
        case taskSummary
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
        typealias Icon = GHIcon

        enum RowType: Hashable {
            case value1, value2, subtitle
            case compactCard
            case button
            case icon, header
            case statistic
            case todo
        }

        var id: UUID
        var rowType: RowType

        var text: String?
        var secondaryText: String?
        var tertiaryText: String?
        var image: UIImage?
        var icon: Icon?
        var isOn: Bool
        var tintColor: UIColor?


        /// Memberwise Initialzier. Not all properties are used in every row type.
        /// - Parameters:
        ///   - id: Unique Identifier of the item
        ///   - rowType: Visual representation of the row
        ///   - text: Primary Text
        ///   - secondaryText: Secondary Text
        ///   - tertiaryText: Tertiary Text
        ///   - image: Image to display
        ///   - icon: Icon to display
        ///   - isOn: Flag to represent the state of a switch with an on/off state
        init(id: UUID = UUID(), rowType: RowType, text: String? = nil, secondaryText: String? = nil, tertiaryText: String? = nil, image: UIImage? = nil, icon: Icon? = nil, isOn: Bool = false, tintColor: UIColor? = .systemBlue) {
            self.id = id
            self.rowType = rowType
            self.text = text
            self.secondaryText = text
            self.tertiaryText = tertiaryText
            self.image = image
            self.icon = icon
            self.isOn = isOn
            self.tintColor = tintColor
        }

        /// Initializer for a UICollectionViewListCell
        /// - Parameters:
        ///   - id: Unique identifier for the item
        ///   - text: The primary text
        ///   - secondaryText: The secondary text
        ///   - image: The image to display
        init(id: UUID = UUID(), rowType: RowType = .value1, text: String? = nil, secondaryText: String? = nil, image: UIImage? = nil) {
            self.init(id: id, rowType: rowType, text: text, secondaryText: secondaryText, image: image)
        }

        /// Initialzier for the Plant Icon
        /// - Parameters:
        ///   - id: Unique identifier for the item
        ///   - icon: The icon
        init(id: UUID = UUID(), icon: Icon?) {
            self.init(id: id, rowType: .icon, icon: icon)
        }

        /// Initializer for the plant header
        /// - Parameters:
        ///   - id: Unique identifier for the item
        ///   - title: The title
        ///   - subtitle: The subtitle
        init(id: UUID = UUID(), title: String?, subtitle: String?) {
            self.init(id: id, rowType: .header, text: title, secondaryText: subtitle)
        }

        /// Initializer for the statistic cell
        /// - Parameters:
        ///   - id: Unique identifier for the item
        ///   - title: The title
        ///   - value: The value
        ///   - unit: The unit
        ///   - icon: The icon
        ///   - tintColor: Primary tint color of the item
        init(id: UUID = UUID(), title: String?, value: String?, unit: String? = nil, image: UIImage? = nil, icon: Icon? = nil, tintColor: UIColor? = nil) {
            self.init(id: id, rowType: .statistic, text: title, secondaryText: value, tertiaryText: unit, image: image, icon: icon, tintColor: tintColor)
        }

        /// Initializer for a todo cell
        /// - Parameters:
        ///   - id: Unique identifier for the item
        ///   - title: The title
        ///   - subtitle: The subtitle
        ///   - image: The image
        ///   - icon: The icon
        ///   - taskState: Flag to represent the state of a switch with an on/off state
        ///   - tintColor: Primary tint color of the item
        init(id: UUID = UUID(), title: String?, subtitle: String?, image: UIImage? = nil, icon: Icon? = nil, taskState: Bool, tintColor: UIColor? = nil) {
            self.init(id: id, rowType: .todo, text: title, secondaryText: subtitle, image: image, icon: icon, isOn: taskState, tintColor: tintColor)
        }

    }
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        view.backgroundColor = .systemGroupedBackground
        view.delegate = self
        return view
    }()
    
    private lazy var plantEditor: PlantEditorControllerController = {
        let editingContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        editingContext.parent = viewContext
        
        let vc = PlantEditorControllerController(plant: plant, viewContext: editingContext)
        vc.delegate = self
        return vc
    }()
    
    // MARK: - View Life Cycle
    
    override func loadView() {
        super.loadView()
        
        configureHiearchy()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = makeDataSource()
        updateUI()
        
        title = "Plant Details"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPlant))
    }
    
    //MARK: - Actions
    @objc private func editPlant() {
        present(plantEditor.wrappedInNavigationController(), animated: true)
    }
}

extension PlantDetailViewController: PlantEditorDelegate {
    func plantEditor(_ editor: PlantEditorControllerController, didUpdatePlant plant: GHPlant) {
        self.plant = plant
        updateUI()
        
        do {
            try viewContext.save()
        } catch {
            viewContext.rollback()
        }
    }
}

private extension PlantDetailViewController {
    func nextTaskDateString() -> String? {
        let nextTasks: [(task: GHTask, date: Date)] = plant.tasks.compactMap { task in
            if let nextDate = task.nextCareDate(after: Calendar.current.startOfDay(for: Date())) {
                return (task, nextDate)
            } else {
                return nil
            }
        }
        
        if let nextTask = nextTasks.min(by: { $0.date < $1.date }) {
            return careDateFormatter.string(from: nextTask.date)
        } else {
            return nil
        }
    }
}

private extension PlantDetailViewController {
    func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let sectionKind = Section.allCases[sectionIndex]
            switch sectionKind {
            case .plantIcon, .plantHeader:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0)
                return section
            case .taskSummary:
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

private extension PlantDetailViewController {
    func makeSnapshot() -> NSDiffableDataSourceSnapshot<Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        
        // Plant Info Header
        snapshot.appendItems([
            Item(icon: plant.icon)
        ], toSection: .plantIcon)

        snapshot.appendItems([
            Item(title: plant.name?.capitalized, subtitle: plant.type?.commonName?.capitalized)
        ], toSection: .plantHeader)
        
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
            Item(title: "Today", value: "\(tasksToday.count)", unit: "\(tasksToday.count == 1 ? "task" : "tasks")", image: UIImage(systemName: "calendar.badge.clock"), tintColor: todayColor),
            Item(title: "Late", value: "\(tasksToday.count)", unit: "\(lateTasks.count == 1 ? "task" : "tasks")", image: UIImage(systemName: "exclamationmark.circle"), tintColor: lateColor)
        ], toSection: .taskSummary)
        
        // Up Next
        let next = lateTasks.union(tasksToday)
        let nextTasks: [Item] = next.map { task -> Item in
            let lastCareString: String
            if task.isLate() {
                guard let lastDate = task.lastCareDate, let expectedDate = task.nextCareDate(after: lastDate) else { fatalError("Unable to calculate days late but task was flagged as late.")}
                let daysLateComponents = Calendar.current.dateComponents([.day, .month], from: expectedDate, to: Calendar.current.startOfDay(for: Date()))
                lastCareString = "\(dateComponentsFormatter.string(from: daysLateComponents) ?? "Not") late"
            } else {
                lastCareString = ""
            }
            return Item(title: task.taskType?.name, subtitle: lastCareString, icon: task.taskType?.icon, taskState: false)
        }
        
        snapshot.appendItems(nextTasks, toSection: .upNext)
        
        // All Tasks
        let items: [Item] = plant.tasks.compactMap { task in
            return Item(rowType: .compactCard, text: task.taskType?.name, secondaryText: task.interval?.intervalText(), icon: task.taskType?.icon)
        }
        
        snapshot.appendItems(items, toSection: .careInfo)
        return snapshot
    }
    
    func makeIconCellRegistration() -> UICollectionView.CellRegistration<IconHeaderCell, Item> {
        UICollectionView.CellRegistration<IconHeaderCell, Item> { cell, _, item in
            if let icon = item.icon {
                var config = cell.iconView.defaultConfiguration()
                config.image = icon.image
                config.tintColor = icon.color
                cell.iconView.configuration = config
            }

            cell.backgroundColor = .systemGroupedBackground
        }
    }

    func makeHeaderCellRegistration() -> UICollectionView.CellRegistration<HeaderCell, Item> {
        UICollectionView.CellRegistration<HeaderCell, Item> { cell, indexPath, item in
            cell.titleLabel.text = item.text
            cell.subtitleLabel.text = item.secondaryText
        }
    }

    func makeStatisticCellRegistration() -> UICollectionView.CellRegistration<StatisticCell, Item> {
        UICollectionView.CellRegistration<StatisticCell, Item> { cell, indexPath, item in
            cell.image = item.image
            cell.title = item.text
            cell.value = item.secondaryText
            cell.unit = item.tertiaryText
            cell.tintColor = item.tintColor

            cell.contentView.backgroundColor = .secondarySystemGroupedBackground
            cell.layer.cornerRadius = 10
            cell.clipsToBounds = true
        }
    }
    
    func makeTodoCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Item> {cell, indexPath, item in
            var config = UIListContentConfiguration.subtitleCell()
            
            config.image = item.icon?.image
            config.imageProperties.tintColor = item.icon?.color
            
            config.text = item.text
            config.secondaryText = item.secondaryText
            
            cell.contentConfiguration = config
            
            if item.isOn {
                cell.accessories = [ .checkmark() ]
            } else {
                let actionHandler: UIActionHandler = {[weak self] _ in
                    guard let self = self else { return }
                    print("👍")
                }
                cell.accessories = [ .todoAccessory(actionHandler: actionHandler) ]
            }
        }
    }
    
    func makeCareInfoCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
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
        let iconRegistration = makeIconCellRegistration()
        let headerCellRegistration = makeHeaderCellRegistration()
        let summaryCellRegistration = makeStatisticCellRegistration()
        let upNextCellRegistration = makeTodoCellRegistration()
        let careInfoCellRegistration = makeCareInfoCellRegistration()
        
        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            let sectionKind = Section.allCases[indexPath.section]
            switch sectionKind {
            case .plantIcon:
                return collectionView.dequeueConfiguredReusableCell(using: iconRegistration, for: indexPath, item: item)
            case .plantHeader:
                return collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration, for: indexPath, item: item)
            case .taskSummary:
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
    
    func updateUI() {
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
