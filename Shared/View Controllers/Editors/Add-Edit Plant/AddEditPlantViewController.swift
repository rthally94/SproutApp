//
//  AddEditPlantTableViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/24/21.
//

import Combine
import CoreData
import UIKit
import SproutKit

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

    private var unconfiguredCareDetailTypes: [SproutCareType] {
        let confguredCareInformation: Set<SproutCareType> = plant?.allCareInformation.reduce(into: Set<SproutCareType>(), { set, info in
            if let typeString = info.type, let type = SproutCareType(rawValue: typeString) {
                set.insert(type)
            }
        }) ?? []

        let allTypes = Set<SproutCareType>(SproutCareType.allCases)
        return allTypes.symmetricDifference(confguredCareInformation).sorted(by: {
            $0.rawValue < $1.rawValue
        })
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
            let template = SproutPlantTemplate.newPlant()
            self.plant = SproutPlantMO.insertNewPlant(using: template, into: editingContext)
        }

        originalNickname = plant?.nickname

        collectionView.collectionViewLayout = makeLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
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

    @objc private func cancelButtonPressed(sender _: AnyObject) {
        discardChangesIfAble { [weak self] success in
            if success {
                self?.dismiss(animated: true)
            }
        }
    }

    @objc private func saveButtonPressed(sender _: AnyObject) {
        saveChanges()
        dismiss(animated: true)
    }

    private func showPlantTypePicker() {
        let vc = PlantTypePickerViewController()
        vc.persistentContainer = storageProvider.persistentContainer
        vc.selectedType = plant?.plantTemplate
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showCareTaskEditor(for task: SproutCareTaskMO) {
        let vc = TaskEditorViewController(task: task, storageProvider: storageProvider)
        vc.storageProvider = storageProvider
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    private func saveChanges() {
        //        delegate?.plantEditor(self, didUpdatePlant: plant)
        storageProvider.saveAllContexts()
    }

    private func discardChangesIfAble(completion: @escaping (Bool) -> Void) {
        func discardChanges() {
            storageProvider.editingContext.rollback()
            storageProvider.saveAllContexts()
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

    // MARK: - Collection View Delegate

    override func collectionView(_: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
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
        case let .button(config):
            config.handler?()
            collectionView.deselectItem(at: indexPath, animated: true)
        case let .listCell(config):
            config.handler?()
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

    func makeDataSource() -> UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item> {
        let iconCellRegistration = makeIconCellRegistration()
        let buttonCellRegistration = makeButtonCellRegistration()
        let textFieldCellRegistration = makeTextFieldCellRegistration()
        let listCellRegistration = makeUICollectionViewListCellRegistration()

        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .plantIcon:
                return collectionView.dequeueConfiguredReusableCell(using: iconCellRegistration, for: indexPath, item: item)
            case .button:
                return collectionView.dequeueConfiguredReusableCell(using: buttonCellRegistration, for: indexPath, item: item)
            case .nameTextField:
                return collectionView.dequeueConfiguredReusableCell(using: textFieldCellRegistration, for: indexPath, item: item)
            case .careDetail, .listCell:
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
            .plantIcon(.init(plant: plant)),
        ])

        // Icon Editor Buttons
        let photoGalleryConfiguration: ButtonConfiguration = {
            var config = ButtonConfiguration.normal()
            config.image = UIImage(systemName: "photo.fill.on.rectangle.fill")
            config.title = "Library"
            config.handler = { [weak self] in
                self?.showImagePicker(preferredType: .photoLibrary)
            }
            return config
        }()

        let cameraConfiguration: ButtonConfiguration = {
            var config = ButtonConfiguration.normal()
            config.image = UIImage(systemName: "camera.fill")
            config.title = "Camera"
            config.handler = { [weak self] in
                self?.showImagePicker(preferredType: .camera)
            }
            return config
        }()

        snapshot.appendSections([.plantIconActions])
        snapshot.appendItems([
            .button(photoGalleryConfiguration),
            .button(cameraConfiguration),
        ])

        // Plant Info

        let plantNicknameTextFieldConfiguration: TextFieldItemConfiguration = {
            TextFieldItemConfiguration(placeholder: "Nickname", initialText: plant.nickname) { [weak self] newValue in
                self?.plantNameTextFieldDidChange(newValue: newValue)
            }
        }()

        let plantTypeConfiguration: ListCellConfiguration = {
            var config = ListCellConfiguration.value()
            config.title = "Plant Type"
            config.value = plant.commonName ?? "Configure"
            config.accessories = [.disclosureIndicator()]
            config.handler = { [weak self] in
                self?.showPlantTypePicker()
            }

            return config
        }()

        snapshot.appendSections([.plantInfo])
        snapshot.appendItems([
            .nameTextField(plantNicknameTextFieldConfiguration),
            .listCell(plantTypeConfiguration),
        ], toSection: .plantInfo)

        // Care Details
        let careDetailItems: [Item] = plant.allCareInformation.compactMap { infoItem in
            if let latestTask = infoItem.latestTask {
                let config = CareDetailItemConfiguration(careTask: latestTask) { [weak self] in
                    self?.showCareTaskEditor(for: latestTask)
                }
                return Item.careDetail(config)
            } else {
                return nil
            }
        }

        if !careDetailItems.isEmpty {
            snapshot.appendSections([.plantCareDetails])
            snapshot.appendItems(careDetailItems, toSection: .plantCareDetails)
        }

        // Unconfigured Care Details
        let unconfiguredCareItems: [Item] = unconfiguredCareDetailTypes.map { templateTask in
            let info = SproutCareInformationMO.fetchOrInsertCareInformation(of: templateTask, for: plant, in: editingContext)
            let config = CareDetailItemConfiguration(careInformation: info) { [weak self] in
                guard let self = self, let plant = self.plant else { return }

                let newTask = SproutCareTaskMO.insertNewTask(of: templateTask, into: self.editingContext)
                plant.addToCareTasks(newTask)
                self.showCareTaskEditor(for: newTask)
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

    func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
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
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: edgeInset, bottom: 16, trailing: edgeInset)
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
            case button(ButtonConfiguration)
            case nameTextField(TextFieldItemConfiguration)
            case careDetail(CareDetailItemConfiguration)
            case listCell(ListCellConfiguration)
        }
    }
}

// MARK: - Collection View Cell Registrations

private extension AddEditPlantViewController {
    func makeIconCellRegistration() -> UICollectionView.CellRegistration<SproutIconCell, Item> {
        UICollectionView.CellRegistration<SproutIconCell, Item> { cell, _, item in
            guard case let .plantIcon(config) = item else { return }

            var cellConfiguration = cell.defaultConfigurtion()
            cellConfiguration.image = config.image
            cell.contentConfiguration = cellConfiguration
            cell.backgroundColor = .systemGroupedBackground
        }
    }

    func makeButtonCellRegistration() -> UICollectionView.CellRegistration<SproutButtonCell, Item> {
        UICollectionView.CellRegistration<SproutButtonCell, Item> { cell, _, item in
            guard case let .button(config) = item else { return }
            cell.image = config.image
            cell.title = config.title
            cell.tintColor = config.tintColor

            switch config.role {
            case .plain:
                cell.displayMode = .plain
            case .normal:
                cell.displayMode = .normal
            case .filled:
                cell.displayMode = .primary
            case .destructive:
                cell.displayMode = .destructive
            }

            cell.layer.cornerRadius = 10
            cell.clipsToBounds = true
        }
    }

    func makeTextFieldCellRegistration() -> UICollectionView.CellRegistration<SproutTextFieldCell, Item> {
        UICollectionView.CellRegistration<SproutTextFieldCell, Item> { cell, _, item in
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
        UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, _, item in
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
                    .disclosureIndicator(),
                ]

            case let .listCell(config):
                cell.contentConfiguration = config.contentConfiguration()
                cell.accessories = config.accessories ?? []
            default:
                break
            }
        }
    }

    func makeSupplementaryHeaderRegistration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { [unowned self] cell, elementKind, indexPath in
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

    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }

        // Apply the new selected image
        plant?.icon = image

        updateUI()
        dismiss(animated: true)
    }
}

// MARK: - Plant Type Picker Delegate

extension AddEditPlantViewController: PlantTypePickerDelegate {
    func plantTypePicker(_: PlantTypePickerViewController, didSelectType plantType: SproutPlantTemplate) {
        plant?.plantTemplate = plantType
        updateUI()
    }
}

// MARK: - Plant Task Editor Delegate

extension AddEditPlantViewController: TaskEditorDelegate {
    internal func taskEditor(_: TaskEditorViewController, didUpdateTask _: SproutCareTaskMO) {
        updateUI()
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension AddEditPlantViewController: UIAdaptivePresentationControllerDelegate {
    // Decides if a pull down gesture should dismiss the editor
    func presentationControllerShouldDismiss(_: UIPresentationController) -> Bool {
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
