//
//  AddEditPlantViewControllerViewModel.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/25/21.
//

import CoreData
import UIKit

enum AddEditPlantView {
    case initial
    case addEditIcon
    case typePicker
    case addEditCareDetail(CareInfo)
}

class AddEditPlantViewControllerViewModel: ObservableObject {
    typealias Section = AddEditPlantCollectionViewController.Section
    typealias Item = AddEditPlantCollectionViewController.Item
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    // MARK: - Properties
    private var plant: SproutPlant

    private(set) var persistentContainer: NSPersistentContainer = AppDelegate.persistentContainer
    private(set) var editingContext: NSManagedObjectContext

    @Published private(set) var presentedView: AddEditPlantView = .initial
    @Published private(set) var snapshot: Snapshot?

    var animateUpdates: Bool = true
    var tintColor: UIColor = .systemBlue

    var navigationTitle: String {
        isNew ? "New Plant" : "Edit Plant"
    }

    var isNew: Bool = false

    var plantIcon: SproutIcon? {
        plant.icon
    }

    var plantName: String? {
        plant.name
    }

    var plantType: SproutPlantType? {
        plant.type
    }

    var careDetails: [CareInfo] {
        guard let careDetailsSet = plant.careInfoItems as? Set<CareInfo> else { return [] }
        return careDetailsSet.sorted(by: {
            switch($0.careCategory?.name, $1.careCategory?.name) {
            case (.some, .some):
                return $0.careCategory!.name! < $1.careCategory!.name!
            case (.some, .none):
                return true
            case (.none, _):
                return false
            }
        })
    }

    // MARK: - Initializers
    init(plant: SproutPlant? = nil, persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        self.editingContext = persistentContainer.viewContext

        if let strongPlant = plant, let editingPlant = editingContext.object(with: strongPlant.objectID) as? SproutPlant {
            self.plant = editingPlant
        } else {
            // Make New Plant
            do {
                isNew = true

                let newPlant = try SproutPlant.createDefaultPlant(inContext: editingContext)
                self.plant = newPlant
            } catch {
                fatalError("Unable to initialize AddEditPlantViewController with new plant: \(error)")
            }
        }
        applySnapshot()
    }

    // MARK: - Intents
    // MARK: Data Persistence
    func saveData() {
        if editingContext.hasChanges {
            do {
                try editingContext.save()
            } catch {
                editingContext.rollback()
            }
        }
    }

    func undoChanges() {
        editingContext.rollback()
    }

    // MARK:
    func setPlantIcon(to newValue: SproutIcon) {
        if let context = plant.managedObjectContext {
            context.perform { [unowned self] in
                guard let icon = context.object(with: newValue.objectID) as? SproutIcon else { return }
                self.plant.icon = icon

                DispatchQueue.main.async {
                    self.applySnapshot()
                }
            }
        }
    }

    func setPlantName(to newValue: String) {
        plant.name = newValue
    }

    func setPlantType(to newValue: SproutPlantType) {
        if let context = plant.managedObjectContext {
            context.perform { [unowned self] in
                guard let type = context.object(with: newValue.objectID) as? SproutPlantType else { return }
                self.plant.type = type

                DispatchQueue.main.async {
                    self.applySnapshot()
                }
            }
        }
    }

    func addToCareDetails(_ newValue: CareInfo) {
        if let context = plant.managedObjectContext {
            context.perform { [unowned self] in
                guard let details = context.object(with: newValue.objectID) as? CareInfo else { return }

                if let detailItems = self.plant.careInfoItems, !detailItems.contains(details) {
                    plant.addToCareInfoItems(details)

                    DispatchQueue.main.async {
                        self.applySnapshot()
                    }
                }
            }
        }
    }

    // MARK: Navigation
    func showInitial() {
        presentedView = .initial
    }

    func addEditPlantIcon() {
        presentedView = .addEditIcon
    }

    func editPlantType() {
        presentedView = .typePicker
    }

    func addEditCareDetail(_ careDetail: CareInfo) {
        presentedView = .addEditCareDetail(careDetail)
    }

    // MARK: Snapshots

    func applySnapshot(animatingDifferences: Bool = true) {
        animateUpdates = animatingDifferences

        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)

        // Plant Icon
        snapshot.appendItems([
            .plantIcon(image: plant.icon?.image, tapAction: .init(handler: { [weak self] in
                print("Plant Icon Tapped.")
                // TODO: Call method to present plant icon editor
                self?.addEditPlantIcon()
            })),
            .normalButton(systemIcon: nil, title: "Edit", tintColor: tintColor, tapAction: .init(handler: { [weak self] in
                print("Edit Button Tapped.")
                // TODO: Call method to present plant icon editor
                self?.addEditPlantIcon()
            }))
        ], toSection: .plantIcon)

        // Plant Info
        snapshot.appendItems([
            .nameTextField(placeholder: "Plant Name", initialText: plant.name, onChange: .init(handler: { [weak self] newName in
                print("Plant name changed: Old(\(self?.plant.name ?? "No Value")) | New(\(newName ?? "No Value"))")
                self?.plant.name = newName
            })),
            .valueCell(image: nil, text: "Plant Type", secondaryText: plant.type?.commonName, accessories: [.disclosureIndicator], tapAction: .init(handler: { [weak self] in
                print("Plant Type Item Tapped.")
                // TODO: Call method to present plant type picker
                self?.editPlantType()
            }))
        ], toSection: .plantInfo)

        // Care Details
        let careScheduleFormatter = Utility.currentScheduleFormatter

        let careDetailSet = (plant.careInfoItems as? Set<CareInfo>) ?? []
        let careDetailItems = careDetailSet.sorted().map { infoItem in
            Item.careDetail(image: infoItem.careCategory?.icon?.image, text: infoItem.careCategory?.name, secondaryText: careScheduleFormatter.string(for: infoItem.currentSchedule), tapAction: .init(handler: { [weak self] in
                print("\(infoItem.careCategory?.name ?? "") Item Tapped.")
                // TODO: Call method to present care detail editor
                self?.addEditCareDetail(infoItem)
            }))
        }
        snapshot.appendItems(careDetailItems, toSection: .plantCareDetails)

        // Unconfigured Care Details
        let request: NSFetchRequest<CareInfo> = CareInfo.unassignedCareInfoItemsFetchRequest()
        let unconfiguredCareDetail = (try? persistentContainer.viewContext.fetch(request)) ?? []
        let unconfiguredCareItems = unconfiguredCareDetail.map { careDetail in
            Item.careDetail(image: careDetail.careCategory?.icon?.image, text: careDetail.careCategory?.name, secondaryText: "Configure", tapAction: .init(handler: {
                print("Unconfigured \(careDetail.careCategory?.name ?? "") Item Tapped.")
                // TODO: Call method to present care detail editor
            }))
        }
        snapshot.appendItems(unconfiguredCareItems, toSection: .unconfiguredCareDetails)

        self.snapshot = snapshot
    }
}
