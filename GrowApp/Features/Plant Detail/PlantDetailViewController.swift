//
//  PlantDetailViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/2/21.
//

import CoreData
import UIKit

enum PlantDetailSection: Int, CaseIterable {
    case plantHero
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

class PlantDetailViewController: StaticCollectionViewController<PlantDetailSection> {
    // MARK: - Properties
    let dateComponentsFormatter = Utility.dateComponentsFormatter
    let careDateFormatter = Utility.relativeDateFormatter

    let viewContext: NSManagedObjectContext
    
    var plant: GHPlant
    
    init(plant: GHPlant, viewContext: NSManagedObjectContext) {
        self.plant = viewContext.object(with: plant.objectID) as! GHPlant
        self.viewContext = viewContext
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var plantEditor: PlantEditorControllerController = {
        let editingContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        editingContext.parent = viewContext
        
        let vc = PlantEditorControllerController(plant: plant, viewContext: editingContext)
        vc.delegate = self
        return vc
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let headerRegistration = makeInsetGroupedSectionHeaderRegistration()
        dataSource.supplementaryViewProvider = { (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            switch elementKind {
            case UICollectionView.elementKindSectionHeader:
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            default:
                return nil
            }
        }

        collectionView.delegate = self
        updateUI()
        
        title = "Plant Details"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPlant))
    }
    
    //MARK: - Actions
    @objc private func editPlant() {
        present(plantEditor.wrappedInNavigationController(), animated: true)
    }

    internal override func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            guard let sectionKind = PlantDetailSection(rawValue: sectionIndex) else { fatalError("Cannot get section for index: \(sectionIndex)") }
            switch sectionKind {
            case .plantHero:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                return section
            case .taskSummary:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.48), heightDimension: .estimated(64))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(64))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .flexible(6)

                let section = NSCollectionLayoutSection(group: group)
                if sectionKind.headerTitle() != nil {
                    let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
                    let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                    section.boundarySupplementaryItems = [headerItem]
                }
                section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 16, bottom: 0, trailing: 16)
                return section
            case .careInfo:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.48), heightDimension: .estimated(64))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(64))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .flexible(6)

                let section = NSCollectionLayoutSection(group: group)
                if sectionKind.headerTitle() != nil {
                    let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
                    let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                    section.boundarySupplementaryItems = [headerItem]
                }
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
                return section
            case .upNext:
                var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                if sectionKind.headerTitle() != nil {
                    config.headerMode = .supplementary
                }
                let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
                return section
            }
        }

        return layout
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
    func makeSnapshot() -> NSDiffableDataSourceSnapshot<PlantDetailSection, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<PlantDetailSection, Item>()
        snapshot.appendSections(PlantDetailSection.allCases)
        
        // Plant Info Header
        snapshot.appendItems([
            .hero(image: plant.icon?.image, title: plant.name, subtitle: plant.type?.commonName)
        ], toSection: .plantHero)
        
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
            Item.statistic(title: "Today", value: "\(tasksToday.count)", unit: "\(tasksToday.count == 1 ? "task" : "tasks")", image: UIImage(systemName: "calendar.badge.clock"), tintColor: todayColor),
            Item.statistic(title: "Late", value: "\(tasksToday.count)", unit: "\(lateTasks.count == 1 ? "task" : "tasks")", image: UIImage(systemName: "exclamationmark.circle"), tintColor: lateColor)
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

            return Item.todo(title: task.taskType?.name, subtitle: lastCareString, image: task.taskType?.icon?.image, taskState: true)
        }
        
        snapshot.appendItems(nextTasks, toSection: .upNext)
        
        // All Tasks
        let items: [Item] = plant.tasks.compactMap { task in
            return Item.compactCardCell(title: task.taskType?.name, value: task.interval?.intervalText(), image: task.taskType?.icon?.image, tapAction: { [unowned self] in
                print(task.taskType?.name ?? "Unknown")
            })
        }
        
        snapshot.appendItems(items, toSection: .careInfo)
        return snapshot
    }

    func makeInsetGroupedSectionHeaderRegistration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { cell, elementKind, indexPath in
            guard elementKind == UICollectionView.elementKindSectionHeader else { return }
            var config = UIListContentConfiguration.largeGroupedHeader()

            guard let section = PlantDetailSection(rawValue: indexPath.section) else { return }
            config.text = section.headerTitle()?.capitalized

            cell.contentConfiguration = config
            cell.contentView.backgroundColor = .systemGroupedBackground
        }
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
        let item = dataSource.itemIdentifier(for: indexPath)
        return item?.isTappable ?? false
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource.itemIdentifier(for: indexPath)
        item?.tapAction?()
    }
}
