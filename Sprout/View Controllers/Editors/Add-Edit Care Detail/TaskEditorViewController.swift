//
//  TaskIntervalEditorController.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/8/21.
//

import CoreData
import UIKit

class TaskEditorViewController: UIViewController {
    // MARK: - Properties

    fileprivate typealias Section = TaskEditorSection
    fileprivate typealias Item = TaskEditorItem

    let dateFormatter = Utility.dateFormatter

    var storageProvider: StorageProvider
    var editingContext: NSManagedObjectContext { storageProvider.editingContext }

    var taskID: NSManagedObjectID
    private var task: SproutCareTaskMO {
        editingContext.object(with: taskID) as! SproutCareTaskMO
    }

    weak var delegate: TaskEditorDelegate?

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    private lazy var imageView = UIImageView(image: UIImage(systemName: "circle"))

    // MARK: - Initializers

    init(task: SproutCareTaskMO, storageProvider: StorageProvider = AppDelegate.storageProvider) {
        taskID = task.objectID
        self.storageProvider = storageProvider

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
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

        applyMainSnapshot(animatingDifferences: false)

        title = "Edit Task"
        //        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
    }

    // MARK: - Actions

    @objc private func doneButtonPressed(_: AnyObject) {
        delegate?.taskEditor(self, didUpdateTask: task)
        storageProvider.saveContext()
        dismiss(animated: true)
    }

    @objc private func cancelButtonPressed(_: AnyObject) {
        delegate?.taskEditorDidCancel(self)
        storageProvider.editingContext.rollback()
        storageProvider.saveContext()
        dismiss(animated: true)
    }

    @objc private func unassignTask(sender _: AnyObject) {
        editingContext.delete(task)
        doneButtonPressed(self)
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

        applyMainSnapshot()
    }

    private func selectFrequency(_ newValue: RepeatFrequencyChoices) {
        guard newValue.rawValue.caseInsensitiveCompare(task.recurrenceFrequency ?? "") != .orderedSame else { return }

        // Update the task interval parameter
        switch newValue {
        case .daily:
            task.schedule = .init(startDate: Date(), recurrenceRule: .daily(1))
        case .weekly:
            task.schedule = .init(startDate: Date(), recurrenceRule: .weekly(1, [1, 2, 3, 4, 5, 6, 7]))
        case .monthly:
            let currentDay = Calendar.current.component(.day, from: Date())
            task.schedule = .init(startDate: Date(), recurrenceRule: .monthly(1, [currentDay]))
        default:
            print("Unknown frequency value: \(newValue)")
            task.schedule = nil
        }

        delegate?.taskEditor(self, didUpdateTask: task)

        applyMainSnapshot()
    }

    func setRecurrenceValue(to newValue: Set<Int>) {
        switch task.recurrenceRule {
        case let .weekly(interval, _):
            task.recurrenceRule = .weekly(interval, newValue)
        case let .monthly(interval, _):
            task.recurrenceRule = .monthly(interval, newValue)
        default:
            return
        }

        delegate?.taskEditor(self, didUpdateTask: task)

        applyMainSnapshot()
    }
}

// MARK: - Collection View Setup

extension TaskEditorViewController {
    // MARK: Layout

    func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [unowned self] sectionIndex, layoutEnvironment in
            let sectionKind = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]
            let section: NSCollectionLayoutSection
            switch sectionKind {
            case .detailHeader:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 16, leading: 16, bottom: 0, trailing: 16)
            default:
                var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                listConfiguration.headerMode = sectionKind.configuration().showsHeader ? .supplementary : .none
                listConfiguration.footerMode = sectionKind.configuration().showsFooter ? .supplementary : .none
                section = NSCollectionLayoutSection.list(using: listConfiguration, layoutEnvironment: layoutEnvironment)
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

        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
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

    private func applyMainSnapshot(animatingDifferences _: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        // Detail Header
        let detailSectionConfiguration = SectionConfiguration()
        let detailItemConfiguration = TaskDetailItemConfiguration(careTask: task)

        snapshot.appendSections([.detailHeader(detailSectionConfiguration)])
        snapshot.appendItems([
            .detailHeader(detailItemConfiguration),
        ])

        // Reminder Toggle
        let reminderToggleSectionConfiguration = SectionConfiguration()
        let enableRemindersConfiguration = ToggleItemConfiguration(text: "Reminders", isOn: task.hasSchedule) { [weak self] newValue in
            self?.setCareScheduleEnabled(to: newValue)
        }

        snapshot.appendSections([.scheduleGeneral(reminderToggleSectionConfiguration)])
        snapshot.appendItems([
            .remindersToggle(enableRemindersConfiguration),
        ])

        // Recurrence Frequency
        let hasSchedule = task.schedule != nil

        if hasSchedule {
            let items: [Item] = RepeatFrequencyChoices.allCases.map { frequency in
                let rowTitle = frequency.rawValue.capitalized

                let isSelected = self.task.recurrenceRule?.frequency == frequency.rawValue

                let configuration = ToggleItemConfiguration(text: rowTitle, isOn: isSelected) { [weak self] _ in
                    self?.selectFrequency(frequency)
                }

                return Item.repeatsIntervalRow(configuration)
            }

            let recurrenceFrequencySectionConfiguration = SectionConfiguration(header: "Repeats")
            snapshot.appendSections([.recurrenceFrequency(recurrenceFrequencySectionConfiguration)])
            snapshot.appendItems(items)
        }

        // Recurrence Values
        let visibleItems: [Item]
        switch task.recurrenceRule {
        case let .weekly(_, currentSelection):
            let dayOfWeekPickerConfiguration = DayOfWeekPickerConfiguration(currentSelection: currentSelection ?? []) { [weak self] picker in
                self?.setRecurrenceValue(to: picker.selection)
            }
            visibleItems = [
                .dayOfWeekPicker(dayOfWeekPickerConfiguration),
            ]

        case let .monthly(_, currentSelection):
            let dayOfMonthPickerConfiguration = DayOfMonthPickerConfiguration(currentSelection: currentSelection ?? []) { [weak self] picker in
                self?.setRecurrenceValue(to: picker.selection)
            }
            visibleItems = [
                .dayOfMonthPicker(dayOfMonthPickerConfiguration),
            ]
        default:
            visibleItems = []
        }

        let recurrenceValueSectionConfiguration = SectionConfiguration()

        if !visibleItems.isEmpty {
            snapshot.appendSections([.recurrenceValue(recurrenceValueSectionConfiguration)])
            snapshot.appendItems(visibleItems)
        }

        UIView.performWithoutAnimation {
            self.dataSource.apply(snapshot)
        }
    }
}

// MARK: - Collection View Delegate

extension TaskEditorViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
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
        case let .repeatsIntervalRow(config):
            config.handler?(false)
        default:
            break
        }

        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: - Cell Registration

private extension TaskEditorViewController {
    func makeDetailHeaderRegistration() -> UICollectionView.CellRegistration<SproutCareDetailCell, Item> {
        UICollectionView.CellRegistration<SproutCareDetailCell, Item> { cell, _, item in
            guard case let .detailHeader(config) = item else { return }
            cell.titleImage = config.taskIcon
            cell.titleText = config.taskName
            cell.valueIcon = config.taskValueIcon
            cell.valueText = config.taskValueText
            cell.tintColor = config.tintColor

            cell.layer.cornerRadius = 10
            cell.clipsToBounds = true
        }
    }

    func makeDayOfWeekPickerRegistration() -> UICollectionView.CellRegistration<SproutDayOfWeekPickerCollectionViewCell, Item> {
        UICollectionView.CellRegistration<SproutDayOfWeekPickerCollectionViewCell, Item> { cell, _, item in
            guard case let .dayOfWeekPicker(config) = item else { return }
            cell.setSelection(config.currentSelection)
            cell.valueChangedAction = UIAction { action in
                guard let picker = action.sender as? DayOfWeekPicker else { return }
                config.handler?(picker)
            }
        }
    }

    func makeDayOfMonthPickerRegistration() -> UICollectionView.CellRegistration<SproutDayOfMonthPickerCollectionViewCell, Item> {
        UICollectionView.CellRegistration<SproutDayOfMonthPickerCollectionViewCell, Item> { cell, _, item in
            guard case let .dayOfMonthPicker(config) = item else { return }
            cell.setSelection(config.currentSelection)
            cell.valueChangedAction = UIAction { action in
                guard let picker = action.sender as? DayOfMonthPicker else { return }
                config.handler?(picker)
            }
        }
    }

    func makeUICollectionViewListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, _, item in
            switch item {
            case let .repeatsIntervalRow(config):
                var contentConfiguration = UIListContentConfiguration.valueCell()
                contentConfiguration.text = config.text
                cell.contentConfiguration = contentConfiguration
                cell.accessories = config.isOn ? [.checkmark()] : []

            case let .remindersToggle(config):
                var contentConfiguration = UIListContentConfiguration.valueCell()
                contentConfiguration.text = config.text
                cell.contentConfiguration = contentConfiguration

                let action = UIAction { action in
                    let newState = (action.sender as? UISwitch)?.isOn ?? false
                    config.handler?(newState)
                }

                cell.accessories = [
                    .toggleAccessory(isOn: config.isOn, action: action),
                ]

            default:
                break
            }
        }
    }

    func createSupplementaryHeaderRegistration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { [unowned self] supplementaryView, _, indexPath in
            let sectionKind = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]

            var config = UIListContentConfiguration.largeGroupedHeader()
            config.text = sectionKind.configuration().headerText
            supplementaryView.contentConfiguration = config
            supplementaryView.contentView.backgroundColor = .systemGroupedBackground
        }
    }
}
