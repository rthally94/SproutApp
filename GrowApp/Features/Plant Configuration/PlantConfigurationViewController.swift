//
//  PlantConfigurationViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/24/21.
//

import UIKit

class PlantConfigurationViewController: UIViewController {
    var model: GrowAppModel
    var onSave: (() -> Void)?
    
    private var _plantIsEditing = false
    internal var _plant: Plant
    
    
    /// Configures the plant configurator for creating a new plant
    /// - Parameter model: The application model
    init(model: GrowAppModel) {
        self.model = model
        
        // 1. Create a new plant in the model
        let newPlant = self.model.plantStore.createPlant()
        newPlant.name = ""
        newPlant.type = PlantType.allTypes[0]
        
        // 2. Store the plant as a deep copy
        _plant = Plant(id: newPlant.id, name: newPlant.name, type: newPlant.type, tasks: newPlant.tasks)
        
        // 3. Set flag as false for new plant
        _plantIsEditing = false
        
        super.init(nibName: nil, bundle: nil)
    }
    
    
    /// Configures the plant configurator for editing an existing plant
    /// - Parameters:
    ///   - plant: The plant to edit
    ///   - model: The application model
    init(plant: Plant, model: GrowAppModel) {
        self.model = model
        
        // 1. Store the plant as a deep copy
        _plant = Plant(id: plant.id, creationDate: plant.creationDate, name: plant.name, type: plant.type, icon: plant.icon, tasks: plant.tasks, careInfo: nil)
        
        // 2. Set flag as true for edting plant
        _plantIsEditing = true
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Data Source View Models
    internal enum Section: Hashable, CaseIterable, CustomStringConvertible {
        case image
        case plantInfo
        case care
        
        var description: String {
            switch self {
            case .image: return "Image"
            case .plantInfo: return "General Information"
            case .care: return "Care Details"
            }
        }
        
        var headerTitle: String? {
            switch self {
            case .care: return description
            default: return nil
            }
        }
        
        var headerMode: UICollectionLayoutListConfiguration.HeaderMode {
            headerTitle == nil ? .none : .supplementary
        }
        
        var footerTitle: String? {
            switch self {
            case .care: return "Add Reminder"
            default: return nil
            }
        }
        
        var footerImage: UIImage? {
            switch self {
            case .care: return UIImage(systemName: "plus")
            default: return nil
            }
        }
        
        var footerMode: UICollectionLayoutListConfiguration.FooterMode {
            footerTitle == nil ? .none : .supplementary
        }
    }
    
    internal struct Item: Hashable {
        static func == (lhs: PlantConfigurationViewController.Item, rhs: PlantConfigurationViewController.Item) -> Bool {
            lhs.rowType == rhs.rowType
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(rowType)
        }
        
        let rowType: RowType
        let onTap: (() -> Void)?
    }
    
    internal enum RowType: Hashable {
        case plantIcon(Icon)
        case list(icon: Icon?, text: String?, secondaryText: String?)
        case listValue(image: UIImage?, text: String?, secondaryText: String?)
        case textField(image: UIImage?, value: String?, placeholder: String?)
    }
    
    internal var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    internal var collectionView: UICollectionView! = nil
    internal var selectedIndexPath: IndexPath?
    
    override func loadView() {
        super.loadView()
        
        configureHiearchy()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .systemGroupedBackground
        configureDataSource()
        
        title = _plantIsEditing ? "Edit Plant" : "New Plant"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(discardChanges))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(applyChanges))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedIndex = selectedIndexPath {
            collectionView.deselectItem(at: selectedIndex, animated: false)
        }
    }
    
    @objc private func applyChanges() {
        // 1. Check for changes
        let modelPlant = model.getPlant(with: _plant.id)
        if let modelPlant = modelPlant, modelPlant != _plant {
            // 2. Apply internal plant's values to model
            modelPlant.name = _plant.name
            modelPlant.type = _plant.type
            modelPlant.icon = _plant.icon
            modelPlant.tasks = _plant.tasks
            
            // 3. Callback to trigger view updates
            onSave?()
        }

        // 3. dismiss
        dismiss(animated: true)
    }
    
    @objc private func discardChanges() {
        // 1. Check for changes
        if !_plantIsEditing {
            // 2. Remove plant from model
            model.deletePlant(_plant)
        }
        
        dismiss(animated: true)
    }
    
    private func updateViews() {
        guard dataSource != nil else { return }
        dataSource.apply(makeSnapshot(from: _plant))
    }
}

extension PlantConfigurationViewController {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout() { sectionIndex, layoutEnvironment in
            let sectionInfo = Section.allCases[sectionIndex]
            
            switch sectionInfo {
            case .image:
                let badgeAnchor = NSCollectionLayoutAnchor(edges: [.bottom], fractionalOffset: CGPoint(x: 1.1, y: 0))
                let badgeSize = NSCollectionLayoutSize(widthDimension: .estimated(44), heightDimension: .estimated(44))
                
                let badge = NSCollectionLayoutSupplementaryItem(layoutSize: badgeSize, elementKind: PlantIconSupplementaryView.badgeElementKind, containerAnchor: badgeAnchor)
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize, supplementaryItems: [badge])
                item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0 )
                return section
            default:
                var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                config.headerMode = sectionInfo.headerMode
                config.footerMode = sectionInfo.footerMode
                
                return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            }
        }
        
        return layout
    }
    
    private func configureHiearchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.delegate = self
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.pinToBoundsOf(view)
    }
}

extension PlantConfigurationViewController: PlantIconPickerDelegate {
    func didChangeIcon(to icon: Icon) {
        if _plant.icon != icon {
            _plant.icon = icon
            updateViews()
        }
    }
}

extension PlantConfigurationViewController: PlantTypePickerDelegate {
    func plantTypePicker(didSelectType type: PlantType) {
        if _plant.type != type {
            _plant.type = type
            updateViews()
        }
    }
}

