//
//  PlantConfigurationViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/24/21.
//

import Combine
import CoreData
import UIKit

internal enum PlantEditorSection: Int, Hashable, CaseIterable, CustomStringConvertible {
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

class PlantEditorControllerController: StaticCollectionViewController<PlantEditorSection> {
    // MARK: - Properties
    var viewContext: NSManagedObjectContext
    weak var delegate: PlantEditorDelegate?
    
    internal var editingPlant: GHPlant
    internal var selectedIndexPath: IndexPath?
    
    // MARK: - Initializers
    
    /// Configures the plant configurator for editing an existing plant
    /// - Parameters:
    ///   - plant: The plant to edit
    ///   - model: The application model
    init(plant: GHPlant, viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        editingPlant = viewContext.object(with: plant.objectID) as! GHPlant
        
        super.init(nibName: nil, bundle: nil)
        
        title = "Edit Plant"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    override func viewDidLoad() {
        super.viewDidLoad()

        configureDataSource()
        collectionView.delegate = self
        
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
    
    internal func showTaskEditor(for task: GHTask) {
        let vc = TaskEditorController(task: task, viewContext: viewContext)
        vc.delegate = self
        navigateTo(vc.wrappedInNavigationController(), modal: true)
    }

    override func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout() { sectionIndex, layoutEnvironment in
            let sectionKind = PlantEditorSection.allCases[sectionIndex]

            switch sectionKind {
            case .image:
                let imageItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let imageItem = NSCollectionLayoutItem(layoutSize: imageItemSize)
                imageItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

                let buttonItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(40))
                let buttonItem = NSCollectionLayoutItem(layoutSize: buttonItemSize)

                let imageGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1.0))
                let imageGroup = NSCollectionLayoutGroup.vertical(layoutSize: imageGroupSize, subitems: [imageItem])

                let mainGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
                let mainGroup = NSCollectionLayoutGroup.vertical(layoutSize: mainGroupSize, subitems: [imageGroup, buttonItem])

                let edgeInset = layoutEnvironment.container.effectiveContentSize.width / 3.5
                let section = NSCollectionLayoutSection(group: mainGroup)
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: edgeInset, bottom: 0, trailing: edgeInset )
                return section
            case .care:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.48), heightDimension: .estimated(64))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(64))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .flexible(6)

                let section = NSCollectionLayoutSection(group: group)
                if sectionKind.headerTitle != nil {
                    let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
                    let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                    section.boundarySupplementaryItems = [headerItem]
                }
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
                return section
            default:
                var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                config.headerMode = sectionKind.headerMode
                config.footerMode = sectionKind.footerMode

                return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            }
        }

        return layout
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

extension PlantEditorControllerController: TaskEditorDelegate {
    func taskEditor(_ editor: TaskEditorController, didUpdateTask task: GHTask) {
        
    }
}
