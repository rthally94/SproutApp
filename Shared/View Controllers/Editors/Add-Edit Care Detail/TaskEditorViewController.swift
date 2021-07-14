//
//  TaskIntervalEditorController.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/8/21.
//

import CoreData
import UIKit
import SproutKit

class TaskEditorViewController: UIViewController {
    // MARK: - Properties
    fileprivate typealias Section = TaskEditorSection
    fileprivate typealias Item = TaskEditorItem

    private let dateFormatter = Utility.dateFormatter
    var editingContext: NSManagedObjectContext

    var taskID: NSManagedObjectID
    private var task: SproutCareTaskMO {
        editingContext.object(with: taskID) as! SproutCareTaskMO
    }

    weak var delegate: TaskEditorDelegate?

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    private lazy var imageView = UIImageView(image: UIImage(systemName: "circle"))

    private let taskHeaderSection = Section(layout: .header, children: [
        .taskHeader
    ])
    private let reminderOptionsSection = Section(layout: .list, children: [
        .remindersSwitch
    ])
    private let recurrenceFrequencySection = Section(header: "Repeats", layout: .list, children: [
        .recurrenceFrequencyChoice(.daily),
        .recurrenceFrequencyChoice(.weekly),
        .recurrenceFrequencyChoice(.monthly),
    ])
    private let recurrenceIntervalSection = Section(layout: .list, children: [
        .dayOfWeekPicker,
        .dayOfMonthPicker
    ])

    private var model: [Section] = []

    // MARK: - Initializers

    init(task: SproutCareTaskMO, editingContext: NSManagedObjectContext) {
        taskID = task.objectID
        self.editingContext = editingContext

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

        updateUIModel(animated: false)
        applyMainSnapshot(animatingDifferences: false)

        title = "Edit Task"
    }

    // MARK: - Actions

    @objc private func doneButtonPressed(_: AnyObject) {
        delegate?.taskEditor(self, didUpdateTask: task)
        dismiss(animated: true)
    }

    @objc private func cancelButtonPressed(_: AnyObject) {
        delegate?.taskEditorDidCancel(self)
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

        updateUIModel()

        if isEnabled {
            var snapshot = dataSource.snapshot()
            snapshot.reloadItems([.taskHeader])
            snapshot.insertSections([recurrenceFrequencySection], afterSection: reminderOptionsSection)
            snapshot.appendItems(recurrenceFrequencySection.children, toSection: recurrenceFrequencySection)
            dataSource.apply(snapshot)
        } else {
            var snapshot = dataSource.snapshot()
            snapshot.reloadItems([.taskHeader])
            snapshot.deleteSections([recurrenceFrequencySection])
            dataSource.apply(snapshot)
        }

        delegate?.taskEditor(self, didUpdateTask: task)
    }

    private func selectFrequency(_ newValue: RepeatFrequencyChoices) {
        guard newValue.rawValue != task.recurrenceFrequency else { return }
        let oldValue = RepeatFrequencyChoices(rawValue: task.recurrenceFrequency ?? "") ?? nil

        // Update the task interval parameter
        switch newValue {
        case .daily:
            task.schedule = .init(startDate: Date(), recurrenceRule: .daily(1))
        case .weekly:
            task.schedule = .init(startDate: Date(), recurrenceRule: .weekly(1, [1, 2, 3, 4, 5, 6, 7]))
        case .monthly:
            let currentDay = Calendar.current.component(.day, from: Date())
            task.schedule = .init(startDate: Date(), recurrenceRule: .monthly(1, [currentDay]))
        }
        updateUIModel()

        var snapshot = dataSource.snapshot()
        let idsToReload: [Item] = [newValue, oldValue]
            .compactMap { choice in
                if let choice = choice {
                    return Item.recurrenceFrequencyChoice(choice)
                } else {
                    return nil
                }
            }
        snapshot.reloadItems(idsToReload)
        snapshot.reloadItems([.taskHeader])

        if newValue == .weekly {
            if !snapshot.sectionIdentifiers.contains(recurrenceIntervalSection) {
                snapshot.appendSections([recurrenceIntervalSection])
            }

            if snapshot.itemIdentifiers(inSection: recurrenceIntervalSection).contains(.dayOfMonthPicker) {
                snapshot.deleteItems([.dayOfMonthPicker])
            }

            snapshot.appendItems([.dayOfWeekPicker], toSection: recurrenceIntervalSection)
        } else if newValue == .monthly {
            if !snapshot.sectionIdentifiers.contains(recurrenceIntervalSection) {
                snapshot.appendSections([recurrenceIntervalSection])
            }

            if snapshot.itemIdentifiers(inSection: recurrenceIntervalSection).contains(.dayOfWeekPicker) {
                snapshot.deleteItems([.dayOfWeekPicker])
            }

            snapshot.appendItems([.dayOfMonthPicker], toSection: recurrenceIntervalSection)
        } else {
            snapshot.deleteSections([recurrenceIntervalSection])
        }

        dataSource.apply(snapshot)

        delegate?.taskEditor(self, didUpdateTask: task)
    }

    private func setRecurrenceValue(to newValue: Set<Int>) {
        let newRule: SproutCareTaskRecurrenceRule
        switch task.recurrenceRule {
        case let .weekly(interval, _):
            newRule = .weekly(interval, newValue)
        case let .monthly(interval, _):
            newRule = .monthly(interval, newValue)
        default:
            return
        }

        if let startDate = task.schedule?.startDate {
            task.schedule = SproutCareTaskSchedule(startDate: startDate, recurrenceRule: newRule)
            updateUIModel()

            var snapshot = dataSource.snapshot()
            snapshot.reloadItems([.taskHeader])
            dataSource.apply(snapshot)
            delegate?.taskEditor(self, didUpdateTask: task)
        }
    }
}

// MARK: - Collection View Setup

extension TaskEditorViewController {
    // MARK: Layout

    func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [unowned self] sectionIndex, layoutEnvironment in
            let sectionKind = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]
            let layoutKind = sectionKind.layout
            let section: NSCollectionLayoutSection
            switch layoutKind {
            case .header:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 16, leading: 16, bottom: 0, trailing: 16)
            case .list:
                var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                listConfiguration.headerMode = sectionKind.showsHeader ? .supplementary : .none
                listConfiguration.footerMode = sectionKind.showsFooter ? .supplementary : .none
                section = NSCollectionLayoutSection.list(using: listConfiguration, layoutEnvironment: layoutEnvironment)
            }

            return section
        }

        layout.register(RoundedRectBackgroundView.self, forDecorationViewOfKind: RoundedRectBackgroundView.ElementKind)

        return layout
    }

    // MARK: Data Source
    private func updateUIModel(animated: Bool = true) {
        let taskHeaderSection = taskHeaderSection
        let reminderOptionsSection = reminderOptionsSection
        let repeatFrequencySection = task.hasSchedule ? recurrenceFrequencySection : nil
        let repeatIntervalSection: Section? = {
            if task.recurrenceFrequency == RepeatFrequencyChoices.weekly.rawValue {
                var section = recurrenceIntervalSection
                section.children = [.dayOfWeekPicker]
                return section
            } else if task.recurrenceFrequency == RepeatFrequencyChoices.monthly.rawValue {
                var section = recurrenceIntervalSection
                section.children = [.dayOfMonthPicker]
                return section
            } else {
                return nil
            }
        }()

        model = [taskHeaderSection, reminderOptionsSection, repeatFrequencySection, repeatIntervalSection].compactMap{$0}
    }

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        let detailHeaderRegistration = makeDetailHeaderRegistration()
        let uiCollectionListCellRegistration = makeUICollectionViewListCellRegistration()
        let dayOfWeekPickerRegistration = makeDayOfWeekPickerRegistration()
        let dayOfMonthPickerRegistration = makeDayOfMonthPickerRegistration()

        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .taskHeader:
                return collectionView.dequeueConfiguredReusableCell(using: detailHeaderRegistration, for: indexPath, item: item)
            case .remindersSwitch, .recurrenceFrequencyChoice(_):
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

    private func applyMainSnapshot(animatingDifferences: Bool = true) {
        for section in model {
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
            sectionSnapshot.append(section.children)
            dataSource.apply(sectionSnapshot, to: section, animatingDifferences: animatingDifferences)
        }
    }
}

// MARK: - Collection View Delegate

extension TaskEditorViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let item = dataSource.itemIdentifier(for: indexPath)
        switch item {
        case .recurrenceFrequencyChoice(let choice) where choice.rawValue != task.recurrenceFrequency:
            return true
        default:
            return false
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource.itemIdentifier(for: indexPath)
        switch item {
        case let .recurrenceFrequencyChoice(choice):
            selectFrequency(choice)
        default:
            break
        }

        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: - Cell Registration

private extension TaskEditorViewController {
    func makeDetailHeaderRegistration() -> UICollectionView.CellRegistration<SproutCareDetailCell, Item> {
        UICollectionView.CellRegistration<SproutCareDetailCell, Item> {[unowned self] cell, _, item in
            cell.titleImage = task.careInformation?.iconImage
            cell.titleText = task.careInformation?.type?.capitalized
            cell.valueIcon = task.hasSchedule ? "bell.fill" : "bell.slash"

            if let schedule = task.schedule {
                cell.valueText = Utility.careScheduleFormatter.string(from: schedule)
            } else {
                cell.valueText = "Not scheduled"
            }
            cell.tintColor = task.careInformation?.tintColor

            cell.layer.cornerRadius = 10
            cell.clipsToBounds = true
        }
    }

    func makeDayOfWeekPickerRegistration() -> UICollectionView.CellRegistration<SproutDayOfWeekPickerCollectionViewCell, Item> {
        UICollectionView.CellRegistration<SproutDayOfWeekPickerCollectionViewCell, Item> {[unowned self] cell, _, item in
            cell.setSelection(task.recurrenceDaysOfWeek ?? [1,2,3,4,5,6,7])
            cell.valueChangedAction = UIAction { action in
                guard let picker = action.sender as? DayOfWeekPicker else { return }
                setRecurrenceValue(to: picker.selection)
            }
        }
    }

    func makeDayOfMonthPickerRegistration() -> UICollectionView.CellRegistration<SproutDayOfMonthPickerCollectionViewCell, Item> {
        UICollectionView.CellRegistration<SproutDayOfMonthPickerCollectionViewCell, Item> {[unowned self] cell, _, item in
            let currentDay = Calendar.current.dateComponents([.day], from: Date()).day ?? 1
            cell.setSelection(task.recurrenceDaysOfMonth ?? [currentDay])
            cell.valueChangedAction = UIAction { action in
                guard let picker = action.sender as? DayOfMonthPicker else { return }
                setRecurrenceValue(to: picker.selection)
            }
        }
    }

    func makeUICollectionViewListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Item> {[unowned self] cell, _, item in
            switch item {
            case let .recurrenceFrequencyChoice(choice):
                let title = choice.rawValue.capitalized
                let isChecked = task.recurrenceFrequency == choice.rawValue

                var contentConfiguration = UIListContentConfiguration.valueCell()
                contentConfiguration.text = title
                cell.contentConfiguration = contentConfiguration
                cell.accessories = isChecked ? [.checkmark()] : []

            case .remindersSwitch :
                let title = "Reminders"
                let isEnabled = task.hasSchedule

                var contentConfiguration = UIListContentConfiguration.valueCell()
                contentConfiguration.text = title
                cell.contentConfiguration = contentConfiguration

                let action = UIAction { action in
                    let newState = (action.sender as? UISwitch)?.isOn ?? false
                    setCareScheduleEnabled(to: newState)
                }

                cell.accessories = [
                    .toggleAccessory(isOn: isEnabled, action: action)
                ]

            default:
                break
            }
        }
    }

    func createSupplementaryHeaderRegistration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { [unowned self] supplementaryView, supplementaryKind, indexPath in
            let sectionKind = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]

            var config = UIListContentConfiguration.largeGroupedHeader()
            switch supplementaryKind {
            case UICollectionView.elementKindSectionHeader:
                config.text = sectionKind.header
            case UICollectionView.elementKindSectionFooter:
                config.text = sectionKind.footer
            default:
                break
            }
            supplementaryView.contentConfiguration = config
            supplementaryView.contentView.backgroundColor = .systemGroupedBackground
        }
    }
}
