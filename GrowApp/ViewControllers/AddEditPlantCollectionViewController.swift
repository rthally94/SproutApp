//
//  AddEditPlantTableViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/24/21.
//

import Combine
import CoreData
import UIKit

class AddEditPlantCollectionViewController: UICollectionViewController {
    // MARK: - Properties
    typealias Section = ViewModel.Section
    typealias Item = ViewModel.Item

    var storageProvider: StorageProvider
    var editingContext: NSManagedObjectContext {
        storageProvider.editingContext
    }

    private(set) var plant: SproutPlant
    private var originalNameValue: String?

    private var unconfiguredCareDetailTypes: [CareCategory] {
        let plantCareInfoItems = (plant.careInfoItems as? Set<CareInfo>) ?? []
        let unconfiguredTypeNames = CareCategory.TaskTypeName.allCases.filter { detailTypeName in
            !plantCareInfoItems.contains(where: { plantCareDetailItem in
                plantCareDetailItem.careCategory?.id == detailTypeName.rawValue
            })
        }

        let context = editingContext
        return unconfiguredTypeNames.compactMap { name in
            try? CareCategory.fetchOrCreateCategory(withName: name, inContext: context)
        }
    }

    weak var delegate: AddEditPlantViewControllerDelegate?
    private var dataSource: UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>!

    // MARK: - Initializers
    init(plant: SproutPlant? = nil, storageProvider: StorageProvider = AppDelegate.storageProvider) {
        self.storageProvider = storageProvider
        let editingContext = storageProvider.editingContext

        // Fetch input plant in editing context or create a new one.
        if let strongPlant = plant, let editingPlant = editingContext.object(with: strongPlant.objectID) as? SproutPlant {
            self.plant = editingPlant
        } else {
            // Make New Plant
            do {
                let newPlant = try SproutPlant.createDefaultPlant(inContext: editingContext)
                self.plant = newPlant
            } catch {
                fatalError("Unable to initialize AddEditPlantViewController with new plant: \(error)")
            }
        }

        originalNameValue = plant?.name

        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.collectionViewLayout = makeLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = navigationTitle
        if isNew {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveButtonPressed))
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonPressed))
            navigationItem.rightBarButtonItem?.isEnabled = false
        }

        collectionView.backgroundColor = .systemGroupedBackground
        dataSource = makeDataSource()

        dismissKeyboardWhenTappedOutside()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.presentationController?.delegate = self
        updateUI()
    }

    // MARK: - Actions
    @objc private func cancelButtonPressed(sender: AnyObject) {
        discardChangesIfAble { [weak self] success in
            if success {
                self?.dismiss(animated: true)
            }
        }
    }

    @objc private func saveButtonPressed(sender: AnyObject) {
        saveChanges()
        dismiss(animated: true)
    }

    private func showPlantIconEditor() {
        let vc = PlantIconPickerController()
        vc.persistentContainer = storageProvider.persistentContainer
        vc.icon = plant.icon
        vc.delegate = self
        present(vc.wrappedInNavigationController(), animated: true)
    }

    private func showPlantTypePicker() {
        let vc = PlantTypePickerViewController()
        vc.persistentContainer = storageProvider.persistentContainer
        vc.selectedType = plant.type
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showCareDetailEditor(for careDetail: CareInfo) {
        let vc = TaskEditorController()
        vc.storageProvider = storageProvider
        vc.task = careDetail
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    private func saveChanges() {
//        delegate?.plantEditor(self, didUpdatePlant: plant)
        self.storageProvider.saveContext()
    }

    private func discardChangesIfAble(completion: @escaping (Bool) -> Void) {
        print(hasChanges, canSave)
        func discardChanges() {
            self.storageProvider.editingContext.rollback()
            self.storageProvider.saveContext()
        }

        if hasChanges {
            let message = isNew ? "Are you sure you want to discard this new plant?" : "Are you sure you want to discard your changes?"
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
            let discardAction = UIAlertAction(title: "Discard Changes", style: .destructive, handler: { _ in
                discardChanges()
                completion(true)
            })
            let continueAction = UIAlertAction(title: "Continue Editing", style: .cancel, handler: { _ in
                completion(false)
            })

            alert.addAction(discardAction)
            alert.addAction(continueAction)
            present(alert, animated: true)
        } else {
            discardChanges()
            completion(true)
        }
    }

    private func updateNavButtons() {
        navigationItem.rightBarButtonItem?.isEnabled = canSave
    }

    private func updateUI(animated: Bool = true) {
        updateNavButtons()
        applySnapshot(animatingDifferences: animated)
    }

    private func createNewDetailItem(for detailTypeName: CareCategory.TaskTypeName) -> CareInfo? {
        do {
            let newCareDetailItem = try CareInfo.createDefaultInfoItem(in: editingContext, ofType: detailTypeName)
            plant.addToCareInfoItems(newCareDetailItem)
            return newCareDetailItem
        } catch {
            print("Unable to create new detail item of type: \(detailTypeName.rawValue) - \(error)")
            return nil
        }
    }

    // MARK: - Collection View Delegate
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let item = dataSource.itemIdentifier(for: indexPath)

        switch item {
        case .nameTextField:
            return false
        default:
            return true
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource.itemIdentifier(for: indexPath)
        switch item {
        case .plantIcon(_, let tapAction):
            tapAction?.handler(Void())
            collectionView.deselectItem(at: indexPath, animated: true)
        case .careDetail(_, _, _, let tapAction):
            tapAction.handler(Void())
        case .normalButton(_, _, _, let tapAction):
            tapAction.handler(Void())
            collectionView.deselectItem(at: indexPath, animated: true)
        case .destructiveButton(_, _, let tapAction):
            tapAction.handler(Void())
            collectionView.deselectItem(at: indexPath, animated: true)
        case .valueCell(_, _, _, _, let tapAction):
            tapAction.handler(Void())
            collectionView.deselectItem(at: indexPath, animated: true)
        default:
            break
        }
    }
}

// MARK: Computed Properties
extension AddEditPlantCollectionViewController {
    private var isNew: Bool {
        plant.isInserted
    }

    private var navigationTitle: String? {
        isNew ? "New Plant" : "Edit Plant"
    }

    private var hasChanges: Bool {
        let areObjectsUpdated = !editingContext.updatedObjects.isEmpty
        let isNameUpdated = originalNameValue != plant.name

        print("isNameUpdated: \(isNameUpdated), areObjectsUpdated: \(areObjectsUpdated)")
        if isNameUpdated {
            print("originalNameValue: \(originalNameValue), plantNameValue: \(plant.name)")
        }

        return areObjectsUpdated || isNameUpdated
    }

    private var canSave: Bool {
        let isPlantValid = plant.isValid()
        return isPlantValid && hasChanges
    }
}

// MARK: - Collection View Setup
extension AddEditPlantCollectionViewController {
    // MARK: Data Source
    internal func makeDataSource() -> UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item> {
        let iconCellRegistration = makeIconCellRegistration()
        let buttonCellRegistration = makeButtonCellRegistration()
        let textFieldCellRegistration = makeTextFieldCellRegistration()
        let listCellRegistration = makeUICollectionViewListCellRegistration()

        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .plantIcon:
                return collectionView.dequeueConfiguredReusableCell(using: iconCellRegistration, for: indexPath, item: item)
            case .normalButton, .destructiveButton:
                return collectionView.dequeueConfiguredReusableCell(using: buttonCellRegistration, for: indexPath, item: item)
            case .nameTextField:
                return collectionView.dequeueConfiguredReusableCell(using: textFieldCellRegistration, for: indexPath, item: item)
            case .careDetail, .valueCell:
                return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: item)
            default:
                return nil
            }
        }

        let headerSupplementaryRegistration = makeSupplementaryHeaderRegistration()
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            switch elementKind {
            case UICollectionView.elementKindSectionHeader:
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerSupplementaryRegistration, for: indexPath)
            default:
                print("No supplementary view for elementKind: \(elementKind)")
                return nil
            }
        }

        return dataSource
    }

    func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)

        // Plant Icon
        snapshot.appendItems([
            .plantIcon(image: plant.icon?.image)
        ], toSection: .plantIcon)

        // Icon Editor Buttons
        snapshot.appendItems([
            .normalButton(systemIcon: "photo.fill.on.rectangle.fill", title: "Gallery", tintColor: view.tintColor, tapAction: .init(handler: { [weak self] in
                print("Gallery Button Tapped.")
                self?.showImagePicker(preferredType: .photoLibrary)
            })),
            .normalButton(systemIcon: "camera.fill", title: "Camera", tintColor: view.tintColor, tapAction: .init(handler: { [weak self] in
                print("Camera Button Tapped.")
                self?.showImagePicker(preferredType: .camera)
            }))
        ], toSection: .plantIconActions)

        // Plant Info
        snapshot.appendItems([
            .nameTextField(placeholder: "Plant Name", initialText: plant.name, onChange: .init(handler: { [weak self] newName in
                print("Plant name changed: Old(\(self?.plant.name ?? "No Value")) | New(\(newName ?? "No Value"))")
                self?.plant.name = newName
                self?.updateNavButtons()
            })),
            .valueCell(image: nil, text: "Plant Type", secondaryText: plant.type?.commonName ?? "Configure", accessories: [.disclosureIndicator], tapAction: .init(handler: { [weak self] in
                print("Plant Type Item Tapped.")
                self?.showPlantTypePicker()
            }))
        ], toSection: .plantInfo)

        // Care Details
        let careScheduleFormatter = Utility.currentScheduleFormatter

        let careDetailSet = (plant.careInfoItems as? Set<CareInfo>) ?? []
        let careDetailItems = careDetailSet.sorted().map { infoItem in
            Item.careDetail(image: infoItem.careCategory?.icon?.image, text: infoItem.careCategory?.name, secondaryText: careScheduleFormatter.string(for: infoItem.currentSchedule), tapAction: .init(handler: { [weak self] in
                print("\(infoItem.careCategory?.name ?? "") Item Tapped.")
                // TODO: Call method to present care detail editor
                self?.showCareDetailEditor(for: infoItem)
            }))
        }
        snapshot.appendItems(careDetailItems, toSection: .plantCareDetails)

        // Unconfigured Care Details
        let unconfiguredCareItems = unconfiguredCareDetailTypes.map { careDetailType in
            Item.careDetail(image: careDetailType.icon?.image, text: careDetailType.name, secondaryText: "Configure", tapAction: .init(handler: { [weak self] in
                print("Unconfigured \(careDetailType.name ?? "") Item Tapped.")
                guard let strongSelf = self else { return }
                guard let detailTypeName = CareCategory.TaskTypeName(rawValue: careDetailType.id ?? ""),
                      let newItem = strongSelf.createNewDetailItem(for: detailTypeName)
                else { return }
                strongSelf.showCareDetailEditor(for: newItem)
            }))
        }
        snapshot.appendItems(unconfiguredCareItems, toSection: .unconfiguredCareDetails)

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    // MARK: Layout
    internal func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout() { sectionIndex, layoutEnvironment in
            let sectionKind = ViewModel.Section.allCases[sectionIndex]

            switch sectionKind {
            case .plantIcon:
                let imageItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let imageItem = NSCollectionLayoutItem(layoutSize: imageItemSize)
                imageItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: imageItem, count: 1)

                let edgeInset = layoutEnvironment.container.effectiveContentSize.width / 3.5
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: edgeInset, bottom: 16, trailing: edgeInset )
                return section
            case .plantIconActions:
                let buttonItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2), heightDimension: .absolute(44))
                let buttonItem = NSCollectionLayoutItem(layoutSize: buttonItemSize)

                let buttonGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
                let buttonGroup = NSCollectionLayoutGroup.horizontal(layoutSize: buttonGroupSize, subitem: buttonItem, count: 2)
                buttonGroup.interItemSpacing = NSCollectionLayoutSpacing.fixed(16)

                let section = NSCollectionLayoutSection(group: buttonGroup)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
                return section
            default:
                var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                config.headerMode = sectionKind.headerText != nil ? .supplementary : .none

                return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            }
        }

        return layout
    }
}

// MARK: Data Source View Model
extension AddEditPlantCollectionViewController {
    enum ViewModel {
        enum Section: CaseIterable {
            case plantIcon
            case plantIconActions
            case plantInfo
            case plantCareDetails
            case unconfiguredCareDetails

            var headerText: String? {
                switch self {
                case .plantCareDetails:
                    return "Care Details"
                default:
                    return nil
                }
            }
        }

        enum Item: Hashable {
            case plantIcon(image: UIImage?, tapAction: HashableClosure<Void>? = nil)
            case normalButton(systemIcon: String?, title: String?, tintColor: UIColor = .systemBlue, tapAction: HashableClosure<Void>)
            case destructiveButton(systemIcon: String?, title: String?, tapAction: HashableClosure<Void>)
            case nameTextField(placeholder: String? = nil, initialText: String? = nil, onChange: HashableClosure<String?>)
            case careDetail(image: UIImage? = nil, text: String? = nil, secondaryText: String? = nil, tapAction: HashableClosure<Void>)
            case valueCell(image: UIImage? = nil, text: String? = nil, secondaryText: String? = nil, accessories: [CellAccessory] = [], tapAction: HashableClosure<Void>)

            enum CellAccessory {
                case disclosureIndicator

                var uiCellAccessory: UICellAccessory {
                    switch self {
                    case .disclosureIndicator:
                        return UICellAccessory.disclosureIndicator()
                    }
                }
            }
        }
    }
}

// MARK: - Collection View Cell Registrations
private extension AddEditPlantCollectionViewController {
    func makeIconCellRegistration() -> UICollectionView.CellRegistration<IconCell, Item> {
        UICollectionView.CellRegistration<IconCell, Item> { cell, indexPath, item in
            guard case let .plantIcon(image, _) = item else { return }

            var config = cell.defaultConfigurtion()
            config.image = image
            cell.contentConfiguration = config
            cell.backgroundColor = .systemGroupedBackground
        }
    }

    func makeButtonCellRegistration() -> UICollectionView.CellRegistration<SproutButtonCell, Item>  {
        UICollectionView.CellRegistration<SproutButtonCell, Item> { cell, indexPath, item in
            switch item {
            case let .normalButton(systemIcon, title, tintColor, _):
                cell.image = UIImage(systemName: systemIcon ?? "")
                cell.title = title
                cell.tintColor = tintColor
                cell.displayMode = .normal
            case let .destructiveButton(systemIcon, title, _):
                cell.image = UIImage(systemName: systemIcon ?? "")
                cell.title = title
                cell.displayMode = .destructive
            default:
                break
            }

            cell.layer.cornerRadius = 10
            cell.clipsToBounds = true
        }
    }

    func makeTextFieldCellRegistration() -> UICollectionView.CellRegistration<SproutTextFieldCell, Item> {
        UICollectionView.CellRegistration<SproutTextFieldCell, Item> { cell, indexPath, item in
            switch item {
            case let .nameTextField(placeholder, initialText, onChange):
                cell.placeholder = placeholder
                cell.value = initialText
                cell.onChange = onChange.handler
                cell.autocapitalizationType = .words
            default:
                break
            }
        }
    }

    func makeUICollectionViewListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            switch item {
            case let .careDetail(image, text, secondaryText, _):
                var config = UIListContentConfiguration.valueCell()
                config.image = image
                config.text = text
                config.secondaryText = secondaryText
                config.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .caption1)
                config.prefersSideBySideTextAndSecondaryText = false
                cell.contentConfiguration = config
                cell.accessories = [
                    .disclosureIndicator()
                ]

            case let .valueCell(image, text, secondaryText, accessories, _):
                var config = UIListContentConfiguration.valueCell()
                config.image = image
                config.text = text
                config.secondaryText = secondaryText
                cell.contentConfiguration = config
                cell.accessories = accessories.map { $0.uiCellAccessory }

            default:
                break
            }
        }
    }

    func makeSupplementaryHeaderRegistration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) {[unowned self] cell, elementKind, indexPath in
            guard elementKind == UICollectionView.elementKindSectionHeader else { return }
            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            var configuration = UIListContentConfiguration.largeGroupedHeader()
            configuration.text = section.headerText
            //            configuration.secondaryText = itemCount == 1 ? "\(itemCount) task" : "\(itemCount) tasks"
            cell.contentConfiguration = configuration
        }
    }
}

// MARK: - Plant Icon Picker Delegate
extension AddEditPlantCollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showImagePicker(preferredType: UIImagePickerController.SourceType = .photoLibrary) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        
        imagePicker.delegate = self

        if UIImagePickerController.isSourceTypeAvailable(preferredType) {
            imagePicker.sourceType = preferredType
        } else {
            imagePicker.sourceType = .photoLibrary
        }

        if imagePicker.sourceType == .camera {
            imagePicker.cameraOverlayView = CameraOverlayView(frame: .zero)
        }

        present(imagePicker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        if plant.icon == nil {
            // If no icon exists, create a new icon
            plant.icon = SproutIcon(context: editingContext)
        }

        // Apply the new selected image
        plant.icon?.imageData = image.pngData()
        updateUI()

        dismiss(animated: true)
    }
}

extension AddEditPlantCollectionViewController: PlantIconPickerControllerDelegate {
    func plantIconPicker(_ picker: PlantIconPickerController, didSelectIcon icon: SproutIcon) {
        plant.icon = icon
        updateUI()
    }
}

// MARK: - Plant Type Picker Delegate
extension AddEditPlantCollectionViewController: PlantTypePickerDelegate {
    func plantTypePicker(_ picker: PlantTypePickerViewController, didSelectType plantType: SproutPlantType) {
        guard let newType = editingContext.object(with: plantType.objectID) as? SproutPlantType else {
            print("Plant Type could not be saved because it does not exist in the editing context.")
            return
        }
        plant.type = newType
        updateUI()
    }
}

// MARK: - Plant Task Editor Delegate
extension AddEditPlantCollectionViewController: TaskEditorDelegate {
    func taskEditor(_ editor: TaskEditorController, didUpdateTask newInfo: CareInfo) {
        updateUI()
    }
}

extension AddEditPlantCollectionViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        discardChangesIfAble { [weak self] success in
            if success {
                self?.dismiss(animated: true)
            }
        }

        return false
    }
}