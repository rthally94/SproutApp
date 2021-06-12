//
//  AddEditPlantTableViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/24/21.
//

import Combine
import CoreData
import UIKit

class AddEditPlantViewController: UICollectionViewController {
    // MARK: - Properties
    typealias Section = ViewModel.Section
    typealias Item = ViewModel.Item

    var storageProvider: StorageProvider
    var editingContext: NSManagedObjectContext {
        storageProvider.editingContext
    }

    private(set) var plant: SproutPlantMO?
    private var originalNickname: String?

    private var unconfiguredCareDetailTypes: [SproutCareTaskMO] {
        let request: NSFetchRequest<SproutCareTaskMO> = SproutCareTaskMO.fetchRequest()
        request.predicate = NSPredicate(format: "%K == true", #keyPath(SproutCareTaskMO.isTemplate))

//        print(String((try? editingContext.count(for: request)) ?? -1))

        let allTemplates: [SproutCareTaskMO]
        do {
            allTemplates = try editingContext.fetch(request)
        } catch {
            print("Unable to fetch all task templates: \(error)")
            allTemplates = []
        }

        let filtered = allTemplates.filter({ template in
            let plantTasks = plant?.allTasks ?? []
            return !plantTasks.contains { task in
                template.taskType == task.taskType
            }
        })

        return filtered
    }

    weak var delegate: AddEditPlantViewControllerDelegate?
    private var dataSource: UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>!

    // MARK: - Initializers
    init(plant: SproutPlantMO? = nil, storageProvider: StorageProvider = AppDelegate.storageProvider) {
        self.storageProvider = storageProvider
        let editingContext = storageProvider.editingContext
        
        // Fetch input plant in editing context or create a new one.
        if let strongPlant = plant, let editingPlant = editingContext.object(with: strongPlant.objectID) as? SproutPlantMO {
            self.plant = editingPlant
        }

        super.init(collectionViewLayout: UICollectionViewFlowLayout())

        if plant == nil {
            SproutPlantMO.createNewPlant(in: editingContext) {[weak self] newPlant in
                DispatchQueue.main.async {
                    self?.plant = newPlant
                }
            }
        }

        originalNickname = plant?.nickname

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

    private func showPlantTypePicker() {
        let vc = PlantTypePickerViewController()
        vc.persistentContainer = storageProvider.persistentContainer
        vc.selectedType = plant
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showCareTaskEditor(for task: SproutCareTaskMO) {
        let vc = TaskEditorController(task: task, storageProvider: storageProvider)
        vc.storageProvider = storageProvider
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    private func saveChanges() {
        //        delegate?.plantEditor(self, didUpdatePlant: plant)
        self.storageProvider.saveContext()
    }

    private func discardChangesIfAble(completion: @escaping (Bool) -> Void) {
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

    //    private func createNewDetailItem(for detailTypeName: CareCategory.TaskTypeName) -> CareInfo? {
    //        do {
    //            let newCareDetailItem = try CareInfo.createDefaultInfoItem(in: editingContext, ofType: detailTypeName)
    //            plant.addToCareInfoItems(newCareDetailItem)
    //            let _ = newCareDetailItem.nextReminder
    //            return newCareDetailItem
    //        } catch {
    //            print("Unable to create new detail item of type: \(detailTypeName.rawValue) - \(error)")
    //            return nil
    //        }
    //    }

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
        case let .careDetail(config):
            config.handler?()
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

// MARK: - Action Handlers
extension AddEditPlantViewController {
    private func plantNameTextFieldDidChange(newValue: String?) {
        guard let plant = plant else { return }
        print("Plant name changed: Old(\(plant.nickname ?? "No Value")) | New(\(newValue ?? "No Value"))")
        plant.nickname = newValue
        updateNavButtons()
    }
}

// MARK: Computed Properties
extension AddEditPlantViewController {
    private var isNew: Bool {
        plant?.isInserted ?? true
    }

    private var navigationTitle: String? {
        isNew ? "New Plant" : "Edit Plant"
    }

    private var hasChanges: Bool {
        let areObjectsUpdated = !editingContext.updatedObjects.isEmpty
        let isNameUpdated = originalNickname != plant?.nickname

//        print("isNameUpdated: \(isNameUpdated), areObjectsUpdated: \(areObjectsUpdated)")
//        if isNameUpdated {
//            print("originalNameValue: \(originalNickname), plantNameValue: \(plant?.nickname)")
//        }

        return areObjectsUpdated || isNameUpdated
    }

    private var canSave: Bool {
        var isPlantValid = true
        do {
            if isNew {
                try plant?.validateForInsert()
            } else {
                try plant?.validateForUpdate()
            }
        } catch {
            print("Validation Error: \(error)")
            isPlantValid = false
        }

        return isPlantValid && hasChanges
    }
}

// MARK: - Collection View Setup
extension AddEditPlantViewController {
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
        guard let plant = plant else { return }

        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        // Plant Icon
        snapshot.appendSections([.plantIcon])
        snapshot.appendItems([
            .plantIcon(.init(plant: plant))
        ])

        // Icon Editor Buttons
        snapshot.appendSections([.plantIconActions])
        snapshot.appendItems([
            .normalButton(systemIcon: "photo.fill.on.rectangle.fill", title: "Gallery", tintColor: view.tintColor, tapAction: .init(handler: { [weak self] in
                print("Gallery Button Tapped.")
                self?.showImagePicker(preferredType: .photoLibrary)
            })),
            .normalButton(systemIcon: "camera.fill", title: "Camera", tintColor: view.tintColor, tapAction: .init(handler: { [weak self] in
                print("Camera Button Tapped.")
                self?.showImagePicker(preferredType: .camera)
            }))
        ])

        // Plant Info
        snapshot.appendSections([.plantInfo])
        snapshot.appendItems([
            .nameTextField(.init(placeholder: "Plant Name", initialText: plant.nickname, handler: { [weak self] newValue in
                guard let self = self else { return }
                self.plantNameTextFieldDidChange(newValue: newValue)
            })),
            .valueCell(image: nil, text: "Plant Type", secondaryText: plant.commonName ?? "Configure", accessories: [.disclosureIndicator], tapAction: .init(handler: { [weak self] in
                print("Plant Type Item Tapped.")
                self?.showPlantTypePicker()
            }))
        ], toSection: .plantInfo)

        // Care Details
        let careDetailSet = plant.allTasks.filter { task in
            task.historyLog == nil
        }

        let careDetailItems: [Item] = careDetailSet.sorted().map { infoItem in
            let config = CareDetailItemConfiguration(careTask: infoItem) { [weak self] in
                self?.showCareTaskEditor(for: infoItem)
            }

            return Item.careDetail(config)
        }

        if !careDetailItems.isEmpty {
            snapshot.appendSections([.plantCareDetails])
            snapshot.appendItems(careDetailItems, toSection: .plantCareDetails)
        }

        // Unconfigured Care Details
        let unconfiguredCareItems: [Item] = unconfiguredCareDetailTypes.map { templateTask in
            let config = CareDetailItemConfiguration(careTask: templateTask) { [weak self] in
                guard let self = self, let plant = self.plant else { return }

                do {
                    try SproutCareTaskMO.createNewTask(from: templateTask) { newTask in
                        plant.addToCareTasks(newTask)
                        self.showCareTaskEditor(for: newTask)
                    }
                } catch {
                    print("Unable to duplicate template task: \(error)")
                }
            }

            return Item.careDetail(config)
        }

        if !unconfiguredCareItems.isEmpty {
            snapshot.appendSections([.unconfiguredCareDetails])
            snapshot.appendItems(unconfiguredCareItems, toSection: .unconfiguredCareDetails)
        }

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
extension AddEditPlantViewController {
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
            case plantIcon(PlantIconItemConfiguration)
            case normalButton(systemIcon: String?, title: String?, tintColor: UIColor = .systemBlue, tapAction: HashableClosure<Void>)
            case destructiveButton(systemIcon: String?, title: String?, tapAction: HashableClosure<Void>)
            case nameTextField(TextFieldItemConfiguration)
            case careDetail(CareDetailItemConfiguration)
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
private extension AddEditPlantViewController {
    func makeIconCellRegistration() -> UICollectionView.CellRegistration<SproutIconCell, Item> {
        UICollectionView.CellRegistration<SproutIconCell, Item> { cell, indexPath, item in
            guard case let .plantIcon(config) = item else { return }

            var cellConfiguration = cell.defaultConfigurtion()
            cellConfiguration.image = config.image
            cell.contentConfiguration = cellConfiguration
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
            case let .nameTextField(config):
                cell.placeholder = config.placeholder
                cell.value = config.initialText
                cell.onChange = config.handler
                cell.autocapitalizationType = .words
            default:
                break
            }
        }
    }

    func makeUICollectionViewListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            switch item {
            case let .careDetail(config):
                var cellConfiguration = UIListContentConfiguration.valueCell()
                cellConfiguration.image = config.image
                cellConfiguration.text = config.title
                cellConfiguration.secondaryText = config.subtitle
                cellConfiguration.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .caption1)
                cellConfiguration.prefersSideBySideTextAndSecondaryText = false
                cell.contentConfiguration = cellConfiguration
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
extension AddEditPlantViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showImagePicker(preferredType: UIImagePickerController.SourceType = .photoLibrary) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self

        if UIImagePickerController.isSourceTypeAvailable(preferredType) {
            imagePicker.sourceType = preferredType
        } else {
            imagePicker.sourceType = .photoLibrary
        }

        present(imagePicker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }

        // Apply the new selected image
        do {
            try plant?.setImage(image)
        } catch {
            print("Error setting image: \(error)")
        }

        updateUI()
        dismiss(animated: true)
    }
}

// MARK: - Plant Type Picker Delegate
extension AddEditPlantViewController: PlantTypePickerDelegate {
    func plantTypePicker(_ picker: PlantTypePickerViewController, didSelectType plantType: SproutPlantMO) {
        editingContext.performAndWait { [unowned self] in
            plant?.scientificName = plantType.scientificName
            plant?.commonName = plantType.commonName
        }
        updateUI()
    }
}

// MARK: - Plant Task Editor Delegate
extension AddEditPlantViewController: TaskEditorDelegate {
    internal func taskEditor(_ editor: TaskEditorController, didUpdateTask newInfo: SproutCareTaskMO) {
        updateUI()
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension AddEditPlantViewController: UIAdaptivePresentationControllerDelegate {
    // Decides if a pull down gesture should dismiss the editor
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {

        if hasChanges {
            discardChangesIfAble { [weak self] success in
                if success {
                    self?.dismiss(animated: true)
                }
            }
        }

        return !hasChanges
    }
}
