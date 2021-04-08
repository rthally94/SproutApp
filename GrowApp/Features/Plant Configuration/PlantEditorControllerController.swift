//
//  PlantConfigurationViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/24/21.
//

import Combine
import CoreData
import UIKit

class PlantEditorControllerController: UIViewController {
    // MARK: - Properties
    var viewContext: NSManagedObjectContext
    weak var delegate: PlantEditorDelegate?
    
    internal var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    
    internal var editingPlant: GHPlant
    internal var selectedIndexPath: IndexPath?
    
    // MARK: - Initializers
    
    /// Configures the plant configurator for editing an existing plant
    /// - Parameters:
    ///   - plant: The plant to edit
    ///   - model: The application model
    init(plant: GHPlant, viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        
        // 1. Store the plant
        editingPlant = viewContext.object(with: plant.objectID) as! GHPlant
        
        super.init(nibName: nil, bundle: nil)
        
        title = "Edit Plant"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Data Source View Models
    internal enum Section: Hashable, CaseIterable, CustomStringConvertible {
        case image
        case plantInfo
        case care
        case actions
        
        var description: String {
            switch self {
            case .image: return "Image"
            case .plantInfo: return "General Information"
            case .care: return "Care Details"
            case .actions: return "Plant Actions"
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
        let rowType: RowType
        var action: (() -> Void)?
        
        init(rowType: RowType) {
            self.rowType = rowType
            self.action = nil
        }
        
        init(rowType: RowType, action: (() -> Void)?) {
            self.rowType = rowType
            self.action = action
        }
        
        static func == (lhs: PlantEditorControllerController.Item, rhs: PlantEditorControllerController.Item) -> Bool {
            lhs.rowType == rhs.rowType
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(rowType)
        }
    }
    
    internal enum RowType: Hashable {
        case plantIcon(GHIcon?)
        case list(icon: GHIcon?, text: String?, secondaryText: String?)
        case listValue(image: UIImage?, text: String?, secondaryText: String?)
        case textField(image: UIImage?, value: String?, placeholder: String?)
        case button(image: UIImage?, text: String?, tintColor: UIColor = .label)
    }
    
    internal var collectionView: UICollectionView! = nil
    
    internal lazy var plantIconPicker: PlantIconPickerController = {
        let vc = PlantIconPickerController(plant: editingPlant, viewContext: viewContext)
        vc.delegate = self
        return vc
    }()
    
    internal lazy var plantTypePicker: PlantTypePickerViewController = {
        let vc = PlantTypePickerViewController(plant: editingPlant, viewContext: viewContext)
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
        
        collectionView.backgroundColor = .systemGroupedBackground
        configureDataSource()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(discardChanges))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(applyChanges))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedIndex = selectedIndexPath {
            collectionView.deselectItem(at: selectedIndex, animated: false)
        }
    }
    
    private func updateUI() {
        guard dataSource != nil else { return }
        dataSource.apply(makeSnapshot(from: editingPlant))
    }
    
    // MARK: - Actions
    @objc private func applyChanges() {
        do {
            try viewContext.save()
        } catch {
            viewContext.rollback()
        }
        
        delegate?.plantEditor(self, didUpdatePlant: editingPlant)
        dismiss(animated: true)
    }
    
    @objc private func discardChanges() {
        viewContext.rollback()
        delegate?.plantEditorDidCancel(self)
        dismiss(animated: true)
    }
}

extension PlantEditorControllerController {
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

extension PlantEditorControllerController: PlantIconPickerControllerDelegate {
    func plantIconPicker(_ picker: PlantIconPickerController, didSelectIcon icon: GHIcon) {
        editingPlant.icon = picker.icon
        updateUI()
    }
}

extension PlantEditorControllerController: PlantTypePickerDelegate {
    func plantTypePicker(_ picker: PlantTypePickerViewController, didSelectType plantType: GHPlantType) {
        editingPlant.type = plantType
        updateUI()
    }
}
