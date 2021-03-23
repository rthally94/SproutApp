//
//  PlantDetailViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/2/21.
//

import UIKit

class PlantDetailViewController: UIViewController {
    static let careDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.formattingContext = .beginningOfSentence
        formatter.unitsStyle = .full
        return formatter
    }()
    
    var plant: Plant? {
        didSet {
            configureSubviews()
        }
    }
    
    enum Section: Hashable, CaseIterable {
        case plantInfo
        case upNext
        case careInfo
        
        func headerTitle() -> String? {
            switch self {
            case .upNext:
                return "Up Next"
            case .careInfo:
                return "Care Info"
            default: return nil
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
        view.backgroundColor = .systemBackground
        view.delegate = self
        return view
    }()
    
    lazy var logCareButton: UIButton = {
        let btn = CapsuleButton(type: .system, primaryAction: .init(title: "Log Care", image: UIImage(systemName: "heart.text.square.fill")) { [unowned self] _ in
            print("🦖 Pressed")
        })
        
        btn.backgroundColor = view.tintColor
        
        return btn
    }()
    
    lazy var dataSource: UICollectionViewDiffableDataSource<Section, Item> = makeDataSource()
    
    override func loadView() {
        super.loadView()
        
        configureHiearchy()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Plant Details"
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
        
        let nextTaskDate = strongPlant.getDateOfNextTask()
        let nextTasks: [Item] = strongPlant.tasksNeedingCare(on: nextTaskDate).map { task in
            Item(id: task.id, icon: task.type.icon, text: task.type.description, secondaryText: <#T##String?#>)
        }
        snapshot.appendItems(nextTasks, toSection: .upNext)
        
        snapshot.appendItems([
            Item(icon: strongPlant.icon, text: strongPlant.name, secondaryText: strongPlant.type.commonName)
        ], toSection: .plantInfo)
        
        let items: [Item] = strongPlant.tasks.map { task in
            let lastCareString: String
            if let lastCareDate = task.lastCareDate {
                lastCareString = "Last: " + PlantDetailViewController.careDateFormatter.localizedString(for: Date(), relativeTo: lastCareDate)
            } else {
                lastCareString = "Last: Never"
            }
            
//            let nextCareString = "Next: " + PlantDetailViewController.careDateFormatter.localizedString(for: task.nextCareDate, relativeTo: Date())
            return Item(id: task.id, icon: task.type.icon, text: task.type.description, secondaryText: lastCareString)
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
        }
    }
    
    func makeUpNextCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, _, item in
            var config = UIListContentConfiguration.subtitleCell()
            
            config.image = item.icon?.image
            config.text = item.text
            config.secondaryText = item.secondaryText
            
            cell.contentConfiguration = config
            cell.accessories = [
                .multiselect()
            ]
        }
    }
    
    func makeCareInfoCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, _, item in
            var config = UIListContentConfiguration.subtitleCell()
            
            if case let .symbol(symbolName, _, _) = item.icon {
                config.image = UIImage(systemName: symbolName)
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
        UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { cell, elementKind, indexPath in
            guard elementKind == UICollectionView.elementKindSectionHeader else { return }
            var config = UIListContentConfiguration.largeGroupedHeader()
            
            let section = Section.allCases[indexPath.section]
            config.text = section.headerTitle()?.capitalized
            
            cell.contentConfiguration = config
        }
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        let headerCellRegistration = makeHeaderCellRegistration()
        let upNextCellRegistration = makeUpNextCellRegistration()
        let careInfoCellRegistration = makeCareInfoCellRegistration()
        
        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            let sectionKind = Section.allCases[indexPath.section]
            switch sectionKind {
            case .plantInfo:
                return collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration, for: indexPath, item: item)
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
            case .careInfo:
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
        logCareButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        view.addSubview(logCareButton)
        
        collectionView.pinToBoundsOf(view)
        NSLayoutConstraint.activate([
            logCareButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -16),
            logCareButton.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            logCareButton.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor)
        ])
    }
    
    func configureSubviews() {
        guard plant != nil else { return }
        
        let snapshot = makeSnapshot()
        dataSource.apply(snapshot)
    }
}

extension PlantDetailViewController: UICollectionViewDelegate {
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
