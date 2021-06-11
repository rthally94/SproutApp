//
//  TaskIntervalEditorController.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/8/21.
//

import CoreData
import UIKit

class TaskEditorController: UIViewController {
    // MARK: - Properties
    fileprivate typealias Section = TaskEditorSection.ID
    fileprivate typealias Item = TaskEditorItem.ID

    fileprivate let sectionStore = AnyModelStore<TaskEditorSection>([
        TaskEditorSection(id: .detailHeader, items: [
            .detailHeader
        ]),
        TaskEditorSection(id: .scheduleGeneral, items: [
            .remindersToggle
        ]),
        TaskEditorSection(id: .recurrenceFrequency, items: [
            .repeatsIntervalRow(.daily),
            .repeatsIntervalRow(.weekly),
            .repeatsIntervalRow(.monthly)
        ], headerText: "Repeats"),
        TaskEditorSection(id: .recurrenceValue, items: [
            .dayOfWeekPicker,
            .dayOfMonthPicker
        ])
    ])

    let dateFormatter = Utility.dateFormatter

    var storageProvider: StorageProvider
    var editingContext: NSManagedObjectContext { storageProvider.editingContext }

    var taskID: NSManagedObjectID
    private var task: SproutCareTaskMO {
        editingContext.object(with: taskID) as! SproutCareTaskMO
    }

    var delegate: TaskEditorDelegate?

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    private lazy var imageView = UIImageView(image: UIImage(systemName: "circle"))

    //MARK: - Initializers
    init(task: SproutCareTaskMO, storageProvider: StorageProvider = AppDelegate.storageProvider) {
        self.taskID = task.objectID
        self.storageProvider = storageProvider

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Life Cycle
    override func loadView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        dataSource = makeDataSource()

        applyInitialSnapshot()

        title = "Edit Task"
        //        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
    }

    // MARK: - Actions
    @objc private func doneButtonPressed(_ sender: AnyObject) {
        delegate?.taskEditor(self, didUpdateTask: task)
        storageProvider.saveContext()
        dismiss(animated: true)
    }

    @objc private func cancelButtonPressed(_ sender: AnyObject) {
        delegate?.taskEditorDidCancel(self)
        storageProvider.editingContext.rollback()
        storageProvider.saveContext()
        dismiss(animated: true)
    }

    @objc private func unassignTask(sender: AnyObject) {
        editingContext.delete(task)
        doneButtonPressed(self)
    }
}

// MARK: - Collection View Setup
extension TaskEditorController {
    // MARK: Layout
    func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {[unowned self] sectionIndex, layoutEnvironment in
            let sectionID = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]
            let sectionKind = self.sectionStore.fetchByID(sectionID)

            let section: NSCollectionLayoutSection
            switch sectionID {
            case .detailHeader:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 16, leading: 16, bottom: 0, trailing: 16)
            default:
                var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                config.headerMode = sectionKind.showsHeader ? .supplementary : .none
                config.footerMode = sectionKind.showsFooter ? .supplementary : .none
                section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            }

            return section
        }

        layout.register(RoundedRectBackgroundView.self, forDecorationViewOfKind: RoundedRectBackgroundView.ElementKind)

        return layout
    }

    // MARK: Data Source
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        let detailHeaderRegistration = makeDetailHeaderRegistration()
        let uiCollectionListCellRegistration = makeUICollectionViewListCellRegistration()
        let dayOfWeekPickerRegistration = makeDayOfWeekPickerRegistration()
        let dayOfMonthPickerRegistration = makeDayOfMonthPickerRegistration()

        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {collectionView, indexPath, item in
            switch item {
            case .detailHeader:
                return collectionView.dequeueConfiguredReusableCell(using: detailHeaderRegistration, for: indexPath, item: item)
            case .remindersToggle, .repeatsIntervalRow:
                return collectionView.dequeueConfiguredReusableCell(using: uiCollectionListCellRegistration, for: indexPath, item: item)
            case .dayOfWeekPicker:
                return collectionView.dequeueConfiguredReusableCell(using: dayOfWeekPickerRegistration, for: indexPath, item: item)
            case .dayOfMonthPicker:
                return collectionView.dequeueConfiguredReusableCell(using: dayOfMonthPickerRegistration, for: indexPath, item: item)
            }
        }

        let headerSupplementaryRegistration = createSupplementaryHeaderRegistration()
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            switch elementKind {
            case UICollectionView.elementKindSectionHeader:
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerSupplementaryRegistration, for: indexPath)
            default:
                return nil
            }
        }

        return dataSource
    }

    private func applyInitialSnapshot() {
        var dataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        let visibleSections = Section.allCases.filter { sectionID in
            switch sectionID {
            case .recurrenceFrequency:
                return self.task.hasSchedule
            case .recurrenceValue:
                return self.task.hasSchedule
            default:
                return true
            }
        }
        dataSourceSnapshot.appendSections(visibleSections)

        let valueSectionNeedsReload = dataSource.snapshot().sectionIdentifiers.contains(.recurrenceValue)^visibleSections.contains(.recurrenceValue)

        dataSource.apply(dataSourceSnapshot)

        // Header Row
        if visibleSections.contains(.detailHeader) {
            applyDetailHeaderSnapshot()
        }

        if visibleSections.contains(.scheduleGeneral) {
            applyScheduleGeneralSnapshot()
        }

        if visibleSections.contains(.recurrenceFrequency) {
            applyFrequencyPickerSnapshot()
        }

        if valueSectionNeedsReload {
            applyValuePickerSnapshot()
        }
    }

    private func applyFrequencyChangedSnapshot() {
        let currentSnapshot = dataSource.snapshot()

        // Header Row
        if currentSnapshot.sectionIdentifiers.contains(.detailHeader) {
            applyDetailHeaderSnapshot()
        }

        if currentSnapshot.sectionIdentifiers.contains(.recurrenceFrequency) {
            applyFrequencyPickerSnapshot()
        }

        if currentSnapshot.sectionIdentifiers.contains(.recurrenceValue) {
            applyValuePickerSnapshot()
        }
    }

    private func applyRecurrenceValueChangedSnapshot() {
        if dataSource.snapshot().sectionIdentifiers.contains(.detailHeader) {
            applyDetailHeaderSnapshot()
        }
    }

    private func applyDetailHeaderSnapshot() {
        // Get the current snapshots
        var detailHeaderSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()

        // Apply the new items to the frequency snapshot
        let currentScheduleFormatter = Utility.careScheduleFormatter
        let scheduleValue = currentScheduleFormatter.string(for: task.schedule) ?? "No schedule"
        let valueIcon = task.schedule == nil ? "bell.slash" : "bell.fill"
        let item = Item.detailHeader

        detailHeaderSnapshot.append([item])
        UIView.performWithoutAnimation {
            self.dataSource.apply(detailHeaderSnapshot, to: .detailHeader)
        }
    }

    private func applyScheduleGeneralSnapshot(after section: Section? = nil) {
        // Get the current snapshots
        var scheduleGeneralSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()

        scheduleGeneralSnapshot.append([
            .remindersToggle
        ])

        UIView.performWithoutAnimation {
            self.dataSource.apply(scheduleGeneralSnapshot, to: .scheduleGeneral)
        }
    }

    private func applyFrequencyPickerSnapshot(after section: Section? = nil) {
        // Get the current snapshots
        var frequencyPickerSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()

        // Apply the new items to the frequency snapshot
        let intervalType = task.recurrenceFrequency ?? ""
        let items: [Item] = RepeatFrequencyChoices.allCases.map { type in
            .repeatsIntervalRow(type)
        }
        frequencyPickerSnapshot.append(items)

        UIView.performWithoutAnimation {
            self.dataSource.apply(frequencyPickerSnapshot, to: .recurrenceFrequency)
        }
    }

    private func applyValuePickerSnapshot() {
        // Get the current snapshots
        var valuePickersSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()

        // Apply the new items to the weekday picker snapshot
        switch task.recurrenceRule {
        case .weekly:
            let weekdayItems = Item.dayOfWeekPicker
            valuePickersSnapshot.append([weekdayItems])
        case .monthly:
            let daysInMonthItem = Item.dayOfMonthPicker
            valuePickersSnapshot.append([daysInMonthItem])
        default:
            break
        }

        UIView.performWithoutAnimation {
            self.dataSource.apply(valuePickersSnapshot, to: .recurrenceValue)
        }
    }

    private func setCareScheduleEnabled(to isEnabled: Bool) {
        if isEnabled {
            let defaultSchedule = SproutCareTaskSchedule(startDate: Date(), recurrenceRule: .daily(1))
            task.schedule = defaultSchedule
        } else {
            if task.schedule != nil {
                task.schedule = nil
            }
        }

        applyFrequencyChangedSnapshot()
    }

    private func selectFrequency(_ newValue: RepeatFrequencyChoices) {
        guard newValue.rawValue.caseInsensitiveCompare(task.recurrenceFrequency ?? "") != .orderedSame else { return }

        // Update the task interval parameter
        switch newValue {
        case .daily:
            task.schedule = .init(startDate: Date(), recurrenceRule: .daily(1))
        case .weekly:
            task.schedule = .init(startDate: Date(), recurrenceRule: .weekly(1, [1]))
        case .monthly:
            task.schedule = .init(startDate: Date(), recurrenceRule: .monthly(1, [1]))
        default:
            print("Unknown frequency value: \(newValue)")
            task.schedule = nil
        }

        delegate?.taskEditor(self, didUpdateTask: task)

        applyFrequencyChangedSnapshot()
    }

    func setIntervalValue(to newValue: Set<Int>) {
        switch task.recurrenceRule {
        case .weekly(let interval, _):
            task.recurrenceRule = .weekly(interval, newValue)
        case .monthly(let interval, _):
            task.recurrenceRule = .monthly(interval, newValue)
        default:
            return
        }

        delegate?.taskEditor(self, didUpdateTask: task)

        applyRecurrenceValueChangedSnapshot()
    }
}

// MARK: - Collection View Delegate
extension TaskEditorController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let item = dataSource.itemIdentifier(for: indexPath)
        switch item {
        case .repeatsIntervalRow:
            return true
        default:
            return false
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource.itemIdentifier(for: indexPath)
        switch item {
        case let .repeatsIntervalRow(value):
            selectFrequency(value)
        default:
            break
        }

        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: - Cell Registration
private extension TaskEditorController {
    func makeDetailHeaderRegistration() -> UICollectionView.CellRegistration<LargeHeaderCell, Item> {
        UICollectionView.CellRegistration<LargeHeaderCell, Item> {[unowned self] cell, indexPath, item in
            let task = self.task
            cell.titleImage = task.taskTypeProperties?.icon
            cell.titleText = task.taskTypeProperties?.displayName
            cell.valueIcon = task.hasSchedule ? "bell.fill" : "bell.slash"
            cell.valueText = Utility.careScheduleFormatter.string(for: task.schedule) ?? "No schedule"

            // TODO: Add tintColor property to task
            cell.tintColor = .systemBlue

            cell.layer.cornerRadius = 10
            cell.clipsToBounds = true
        }
    }

    func makeDayOfWeekPickerRegistration() -> UICollectionView.CellRegistration<SproutDayOfWeekPickerCollectionViewCell, Item> {
        UICollectionView.CellRegistration<SproutDayOfWeekPickerCollectionViewCell, Item> { [unowned self] cell, indexPath, item in
            cell.setSelection(self.task.recurrenceDaysOfWeek ?? [1])
            cell.valueChangedAction = UIAction {[weak self] action in
                guard let picker = action.sender as? DayOfWeekPicker else { return }
                self?.setIntervalValue(to: picker.selection)
            }
        }
    }

    func makeDayOfMonthPickerRegistration() -> UICollectionView.CellRegistration<SproutDayOfMonthPickerCollectionViewCell, Item> {
        UICollectionView.CellRegistration<SproutDayOfMonthPickerCollectionViewCell, Item> { [unowned self] cell, indexPath, item in
            cell.setSelection(self.task.recurrenceDaysOfMonth ?? [1])
            cell.valueChangedAction = UIAction {[weak self] action in
                guard let picker = action.sender as? DayOfMonthPicker else { return }
                self?.setIntervalValue(to: picker.selection)
            }
        }
    }


    func makeUICollectionViewListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Item> {[unowned self] cell, indexPath, item in
            switch item {
            case let .repeatsIntervalRow(value):
                var config = UIListContentConfiguration.valueCell()
                config.text = value.rawValue.capitalized
                cell.contentConfiguration = config
                let isSelected = self.task.recurrenceFrequency?.compare(value.rawValue) == .orderedSame
                cell.accessories = isSelected ? [.checkmark()] : []

            case .remindersToggle:
                var config = UIListContentConfiguration.valueCell()
                // TODO: Source constant from view model
                config.text = "Reminders"

                cell.contentConfiguration = config

                let action = UIAction {[unowned self] action in
                    let newState = (action.sender as? UISwitch)?.isOn ?? false
                    self.setCareScheduleEnabled(to: newState)
                }

                let isOn = self.task.hasSchedule

                // TODO: Replace constant with value from view model
                cell.accessories = [
                    .toggleAccessory(isOn: isOn, action: action)
                ]

            default:
                break
            }
        }
    }

    func createSupplementaryHeaderRegistration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) {[unowned self] supplementaryView, elementKind, indexPath in
            let sectionID = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            let section = self.sectionStore.fetchByID(sectionID)

            var config = UIListContentConfiguration.largeGroupedHeader()
            config.text = section.headerText
            supplementaryView.contentConfiguration = config
            supplementaryView.contentView.backgroundColor = .systemGroupedBackground
        }
    }
}
