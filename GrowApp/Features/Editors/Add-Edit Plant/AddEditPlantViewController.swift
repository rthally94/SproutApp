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
    case plantCare
    case unconfiguredCare
    case actions

    var description: String {
        switch self {
        case .image: return "Image"
        case .plantInfo: return "General Information"
        case .plantCare: return "Care Details"
        case .unconfiguredCare: return "Unconfigured Tasks"
        case .actions: return "Plant Actions"
        }
    }

    var headerTitle: String? {
        switch self {
        case .plantCare: return description
        default: return nil
        }
    }

    var headerMode: UICollectionLayoutListConfiguration.HeaderMode {
        headerTitle == nil ? .none : .supplementary
    }

    var footerTitle: String? {
        switch self {
        case .plantCare: return "Add Reminder"
        default: return nil
        }
    }

    var footerImage: UIImage? {
        switch self {
        case .plantCare: return UIImage(systemName: "plus")
        default: return nil
        }
    }

    var footerMode: UICollectionLayoutListConfiguration.FooterMode {
        footerTitle == nil ? .none : .supplementary
    }
}

class AddEditPlantViewController: StaticCollectionViewController<PlantEditorSection> {
    // MARK: - Properties
    var persistentContainer: NSPersistentContainer = AppDelegate.persistentContainer
    weak var delegate: AddEditPlantViewControllerDelegate?

    var viewModel: AddEditPlantViewControllerViewModel!

    private var selectedIndexPath: IndexPath?

    internal lazy var plantTypePicker: PlantTypePickerViewController = {
        let vc = PlantTypePickerViewController()
        vc.persistentContainer = persistentContainer
        vc.selectedType = viewModel.plantType
        vc.delegate = self
        return vc
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(viewModel != nil, "The viewModel property must be assigned before presenting \(self)")
        
        persistentContainer.viewContext.undoManager?.beginUndoGrouping()

        title = viewModel.navigationTitle

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

    // MARK: - UI Configuration
    private func updateUI() {
        guard dataSource != nil else { return }
//        dataSource.apply(makeSnapshot(from: plant))
    }

    override func makeLayout() -> UICollectionViewLayout {
        return plantEditorLayout()
    }
    
    // MARK: - Actions
    @objc private func applyChanges() {
        persistentContainer.viewContext.undoManager?.endUndoGrouping()
//        cleanupUnusuedTasks()
//        delegate?.plantEditor(self, didUpdatePlant: plant)
        dismiss(animated: true)
    }
    
    @objc private func discardChanges() {
        persistentContainer.viewContext.undoManager?.endUndoGrouping()
        persistentContainer.viewContext.undoManager?.undoNestedGroup()
//        cleanupUnusuedTasks()
        delegate?.plantEditorDidCancel(self)
        dismiss(animated: true)
    }

    func showIconEditor() {
        let vc = PlantIconPickerController()
        vc.persistentContainer = persistentContainer
//        vc.icon = icon
        vc.delegate = self
        navigateTo(vc.wrappedInNavigationController(), modal: true)
    }

    func showTaskEditor(for task: CareInfo) {
        let vc = TaskEditorController()
        vc.task = task
        vc.delegate = self
        navigateTo(vc.wrappedInNavigationController(), modal: true)
    }

    func deletePlant() {
//        persistentContainer.viewContext.delete(plant)
        applyChanges()
    }

    func cleanupUnusuedTasks() {
        let allUnconfiguredTasksRequest: NSFetchRequest<CareInfo> = CareInfo.fetchRequest()
        allUnconfiguredTasksRequest.predicate = NSPredicate(format: "%K == nil", #keyPath(CareInfo.plant))
        do {
            let allUnconfigredTasks = try persistentContainer.viewContext.fetch(allUnconfiguredTasksRequest)
            allUnconfigredTasks.forEach {
                persistentContainer.viewContext.delete($0)
            }
            print("Cleaned \(allUnconfigredTasks.count) care items.")
        } catch {
            print(error)
        }
    }
}

// MARK: - Collection View Configuration
private extension AddEditPlantViewController {
    private func plantEditorLayout() -> UICollectionViewLayout {
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
                mainGroup.interItemSpacing = .fixed(10)

                let edgeInset = layoutEnvironment.container.effectiveContentSize.width / 3.5
                let section = NSCollectionLayoutSection(group: mainGroup)
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: edgeInset, bottom: 0, trailing: edgeInset )
                return section
            case .plantCare, .unconfiguredCare:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(64))
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

// MARK: - UICollectionViewDelegate
extension AddEditPlantViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        return item.isTappable
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        if let action = item.tapAction {
            selectedIndexPath = indexPath

            action()
        }
    }

    func navigateTo(_ destination: UIViewController, modal: Bool = false) {
        if let navigationController = navigationController, modal == false {
            navigationController.pushViewController(destination, animated: true)
        } else {
            present(destination, animated: true)
        }
    }
}


// MARK: - PlantIconPickerDelegate
extension AddEditPlantViewController: PlantIconPickerControllerDelegate {
    func plantIconPicker(_ picker: PlantIconPickerController, didSelectIcon icon: SproutIcon) {
        viewModel.setPlantIcon(to: icon)
        updateUI()
    }
}

// MARK: - PlantTypePickerDelegate
extension AddEditPlantViewController: PlantTypePickerDelegate {
    func plantTypePicker(_ picker: PlantTypePickerViewController, didSelectType plantType: SproutPlantType) {
        viewModel.setPlantType(to: plantType)
        updateUI()
    }
}

// MARK: - PlantTaskEditroDelegate
extension AddEditPlantViewController: TaskEditorDelegate {
    func taskEditor(_ editor: TaskEditorController, didUpdateTask newInfo: CareInfo) {
        viewModel.addToCareDetails(newInfo)
        updateUI()
    }
}
