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
    typealias Section = PlantEditorSection
    typealias Item = AddEditPlantViewController.Item
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    // MARK: - Properties
    private var plant: GHPlant
    var persistentContainer: NSPersistentContainer
    private var editingContext: NSManagedObjectContext

    @Published private(set) var presentedView: AddEditPlantView = .initial
    @Published private(set) var snapshot: Snapshot?

    var navigationTitle: String {
        isNew ? "New Plant" : "Edit Plant"
    }

    var isNew: Bool = false

    var plantName: String? {
        plant.name
    }

    var plantType: GHPlantType? {
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
    init(plant: GHPlant? = nil, persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        self.editingContext = persistentContainer.viewContext

        if let strongPlant = plant, let editingPlant = editingContext.object(with: strongPlant.objectID) as? GHPlant {
            self.plant = editingPlant
        } else {
            // Make New Plant
            do {
                isNew = true

                let newPlant = try GHPlant.createDefaultPlant(inContext: editingContext)
                self.plant = newPlant
            } catch {
                fatalError("Unable to initialize AddEditPlantViewController with new plant: \(error)")
            }
        }
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
            }
        }
    }

    func setPlantName(to newValue: String) {
        plant.name = value
    }

    func setPlantType(to newValue: GHPlantType) {
        if let context = plant.managedObjectContext {
            context.perform { [unowned self] in
                guard let type = context.object(with: newValue.objectID) as? GHPlantType else { return }
                self.plant.type = type
            }
        }
    }

    func addToCareDetails(_ newValue: CareInfo) {
        if let context = plant.managedObjectContext {
            context.perform { [unowned self] in
                guard let details = context.object(with: newValue.objectID) as? CareInfo else { return }

                if let detailItems = self.plant.careInfoItems, !detailItems.contains(details) {
                    plant.addToCareInfoItems(details)
                }
            }
        }
    }

    // MARK: Navigation
    func showPlantDetail() {
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

    private func updateSnapshot() {
        if var strongSnapshot = snapshot {
            strongSnapshot = updatePlantIconIfNeeded(in: strongSnapshot)
            strongSnapshot = updatePlantInfoIfNeeded(in: strongSnapshot)

            snapshot = strongSnapshot
        } else {
            snapshot = createInitalSnapshot()
        }
    }

    private func createInitalSnapshot() -> NSDiffableDataSourceSnapshot<Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<PlantEditorSection, Item>()
        snapshot.appendSections(PlantEditorSection.allCases)

        // Header Image
        snapshot.appendItems([
            RowItem.icon(image: plant.icon?.image, tapAction: { [unowned self] in
                self.addEditPlantIcon()
            }),

            RowItem.button(context: .normal, title: "Edit", onTap: {[unowned self] in
                self.addEditPlantIcon()
            })
        ], toSection: .image)

        // General Plant Info
        snapshot.appendItems([
            Item.textField(placeholder: "My New Plant", initialValue: plant.name, onChange: { [unowned self] newValue in
                guard let value = newValue as? String else { return }
                self.setPlantName(to: value)
            }),
            Item.listCell(rowType: .value2, text: "Type", secondaryText: plant.type?.commonName ?? "Choose Type", accessories: [.disclosureIndicator()], tapAction: { [unowned self] in
                self.editPlantType()
            })
        ], toSection: .plantInfo)

        // Plant Tasks
        let tasks: [Item] = plant.tasks.compactMap { task in
            Item.compactCardCell(title: task.careCategory?.name, value: task.currentSchedule?.recurrenceRule?.intervalText(), image: task.careCategory?.icon?.image, tapAction: {[unowned self] in
                print(task.careCategory?.name ?? "Unknown")
                self.addEditCareDetail(task)
            })
        }
        snapshot.appendItems(tasks, toSection: .plantCare)

        let unassignedTasks: [Item] = CareCategory.TaskTypeName.allCases.compactMap { type in
            if !plant.tasks.contains(where: { $0.careCategory?.name == type.description }), let task = try? CareInfo.createDefaultInfoItem(in: persistentContainer.viewContext, ofType: type) {
                task.currentSchedule = CareSchedule.dailySchedule(interval: 1, context: persistentContainer.viewContext)
                return Item.compactCardCell(title: task.careCategory?.name, value: "Tap to configure", image: task.careCategory?.icon?.image, tapAction: {[unowned self] in
                    print(task.careCategory?.name ?? "Unknown")
                    plant.addToCareInfoItems(task)
                    self.addEditCareDetail(task)
                })
            } else {
                return nil
            }
        }

        snapshot.appendItems(unassignedTasks, toSection: .unconfiguredCare)

        if !isNew {
            let deleteItem = Item.button(context: .destructive, title: "Delete Plant", image: UIImage(systemName: "trash.fill"), onTap: {[unowned self] in
//                deletePlant()
            })
            snapshot.appendItems([deleteItem], toSection: .actions)
        }
    }

    private func updatePlantIconIfNeeded(in editingSnapshot: NSDiffableDataSourceSnapshot<Section, Item>) -> NSDiffableDataSourceSnapshot<Section, Item> {
        var editingSnapshot = editingSnapshot

        let plantIconIndex = 0

        if plant.icon?.hasChanges == true {
            let oldIconItem = editingSnapshot.itemIdentifiers(inSection: .image)[plantIconIndex]
            var newIconItem = oldIconItem
            newIconItem.image = plant.icon?.image

            editingSnapshot.insertItems([newIconItem], afterItem: oldIconItem)
            editingSnapshot.deleteItems([oldIconItem])
        }

        return editingSnapshot
    }

    private func updatePlantInfoIfNeeded(in editingSnapshot: NSDiffableDataSourceSnapshot<Section, Item>) -> NSDiffableDataSourceSnapshot<Section, Item> {
        var editingSnapshot = editingSnapshot

        let plantTextFieldIndex = 0
        let plantTypeIndex = 1

        // Update textField text if needed
        let oldTextFieldItem = editingSnapshot.itemIdentifiers(inSection: .plantInfo)[plantTextFieldIndex]
        if plant.name != oldTextFieldItem.secondaryText {
            var newTextFieldItem = oldTextFieldItem
            newTextFieldItem.secondaryText = plant.name

            editingSnapshot.insertItems([newTextFieldItem], afterItem: oldTextFieldItem)
            editingSnapshot.deleteItems([newTextFieldItem])
        }

        // Update plant type if needed
        if plant.type?.hasChanges == true {
            let oldTypeItem = editingSnapshot.itemIdentifiers(inSection: .plantInfo)[plantTypeIndex]
            var newTypeItem = oldTypeItem
            newTypeItem.secondaryText = plant.type?.commonName ?? "Select Type"

            editingSnapshot.insertItems([newTypeItem], afterItem: oldTypeItem)
            editingSnapshot.deleteItems([oldTypeItem])
        }

        return editingSnapshot
    }

    private func updateCareDetails(in editingSnapshot: NSDiffableDataSourceSnapshot<Section, Item>) -> NSDiffableDataSourceSnapshot<Section, Item> {
        var editingSnapshot = editingSnapshot

        let careDetailItems = (plant.careInfoItems as? Set<CareInfo> ?? []).sorted()

        // Update plant care details
        for careDetailItem in careDetailItems {
            if careDetailItem.hasChanges {
                guard let oldDetailItem = editingSnapshot.itemIdentifiers(inSection: .plantCare).first(where: { $0.text == careDetailItem.careCategory?.name }) else { continue }
                let newDetailItem = Item.compactCardCell(id: oldDetailItem.id, title: careDetailItem.careCategory?.name, value: careDetailItem.currentSchedule?.recurrenceRule?.intervalText(), image: careDetailItem.careCategory?.icon?.image, tapAction: { [unowned self] in
                    print(careDetailItem.careCategory?.name ?? "Unknown")
                    self.addEditCareDetail(careDetailItem)
                })

                editingSnapshot.insertItems([newDetailItem], afterItem: oldDetailItem)
                editingSnapshot.deleteItems([oldDetailItem])
            }
        }

        // Update unassigned care detail items
        

        return editingSnapshot
    }
}
