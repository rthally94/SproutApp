//
//  TaskIntervalEditorController.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/8/21.
//

import CoreData
import UIKit

enum TaskEditorSection: Int, Hashable, CaseIterable {
    case header, notes, recurrenceFrequency, recurrenceValue, actions

    var headerTitle: String? {
        switch self {
        case .notes:
            return "Notes"
        case .recurrenceFrequency:
            return "Repeats"
        default:
            return nil
        }
    }
}

class TaskEditorController: StaticCollectionViewController<TaskEditorSection> {
    let dateFormatter = Utility.dateFormatter
    var persistentContainer: NSPersistentContainer = AppDelegate.persistentContainer
    var delegate: TaskEditorDelegate?
    var task: CareInfo?

    private let repeatFrequencyChoices = [
        SproutRecurrenceFrequency.daily,
        SproutRecurrenceFrequency.weekly,
        SproutRecurrenceFrequency.monthly
    ]

    private lazy var imageView = UIImageView(image: UIImage(systemName: "circle"))

    private func makeWeekdayPicker() -> [Item] {
        let values = task?.careSchedule?.recurrenceRule?.daysOfTheWeek ?? []
        let items: [Item] = Array(1...7).map { value in
            let title = Calendar.current.veryShortStandaloneWeekdaySymbols[value-1]

            var item = Item.circleButtonCell(text: title, isSelected: values.contains(value), tapAction: {
                self.repeatValueButtonTapped(value)
            })
            item.tag = value
            return item
        }

        return items
    }

    private func makeDayPicker() -> [Item] {
        let values = task?.careSchedule?.recurrenceRule?.daysOfTheMonth ?? []
        let items: [Item] = Array(1...31).map { value in
            let title = String(value)

            var item = Item.circleButtonCell(text: title, isSelected: values.contains(value), tapAction: {
                self.repeatValueButtonTapped(value)
            })
            item.tag = value
            return item
        }

        return items
    }

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        persistentContainer.viewContext.undoManager?.beginUndoGrouping()

        assert(task != nil, "TaskEditorViewController --- Task cannot be \"nil\". Set the property before presenting.")

        collectionView.delegate = self

        let headerSupplementartyRegistration = createSupplementaryHeaderRegistration()

        dataSource.supplementaryViewProvider = .init() { collectionView, supplementaryKind, indexPath in
            switch supplementaryKind {
            case UICollectionView.elementKindSectionHeader:
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerSupplementartyRegistration, for: indexPath)
            default:
                return nil
            }
        }

        applyDefaultSnapshot()

        title = "Edit Task"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
    }

    override func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            guard let sectionKind = TaskEditorSection(rawValue: sectionIndex) else { fatalError("Section index not available: \(sectionIndex)") }
            switch sectionKind {
            case .header:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 16, leading: 16, bottom: 0, trailing: 16)
                return section
            case .recurrenceValue:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/7), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1/7))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 24, bottom: 6, trailing: 24)
                section.decorationItems = [
                    NSCollectionLayoutDecorationItem.background(elementKind: RoundedRectBackgroundView.ElementKind)
                ]
                return section
            default:
                var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                config.headerMode = sectionKind.headerTitle != nil ? .supplementary : .none
                return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            }
        }

        layout.register(RoundedRectBackgroundView.self, forDecorationViewOfKind: RoundedRectBackgroundView.ElementKind)

        return layout
    }

    // MARK: - Actions
    @objc private func doneButtonPressed(_ sender: AnyObject) {
        if let task = task {
            delegate?.taskEditor(self, didUpdateTask: task)
        }

        persistentContainer.viewContext.undoManager?.endUndoGrouping()
        dismiss(animated: true)
    }

    @objc private func cancelButtonPressed(_ sender: AnyObject) {
        delegate?.taskEditorDidCancel(self)
        persistentContainer.viewContext.undoManager?.endUndoGrouping()
        persistentContainer.viewContext.undoManager?.undoNestedGroup()
        dismiss(animated: true)
    }

    private func unassignTask() {
        if let task = task {
            persistentContainer.viewContext.delete(task)
            //            self.task = nil
        }
        doneButtonPressed(self)
    }

    @objc private func repeatValueButtonTapped(_ value: Int) {
        // TODO: Add support for updating values

        var oldValues: Set<Int>
        let rule = task?.careSchedule?.recurrenceRule
        switch rule?.frequency {
        case .weekly:
            oldValues = rule?.daysOfTheWeek ?? []
        case .monthly:
            oldValues = rule?.daysOfTheMonth ?? []
        default:
            oldValues = []
        }

        if oldValues.contains(value) == true && oldValues.count > 1 {
            oldValues.remove(value)
        } else {
            oldValues.insert(value)
        }
        setIntervalValue(to: oldValues)
    }
}

extension TaskEditorController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let item = dataSource.itemIdentifier(for: indexPath)
        return item?.isTappable ?? false
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource.itemIdentifier(for: indexPath)
        item?.tapAction?()
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension TaskEditorController {
    func updateUI() {
        applyDefaultSnapshot()
    }
    
    private func applyDefaultSnapshot() {
        var dataSourceSnapshot = NSDiffableDataSourceSnapshot<TaskEditorSection, Item>()
        let visibleSections = TaskEditorSection.allCases.filter {
            // Show the value picker only if the frequency is .weekly or .monthly
            guard $0 == .recurrenceValue else { return true }
            return task?.careSchedule?.recurrenceRule?.frequency == .weekly || task?.careSchedule?.recurrenceRule?.frequency == .monthly
        }
        dataSourceSnapshot.appendSections(visibleSections)
        
        // Header Row
        dataSourceSnapshot.appendItems([
            Item.largeHeader(title: task?.careCategory?.name, value: task?.careSchedule?.recurrenceRule?.intervalText(), image: task?.careCategory?.icon?.image, tintColor: task?.careCategory?.icon?.color)
        ], toSection: .header)

        dataSourceSnapshot.appendItems([
            Item.textField(placeholder: "Add Note", initialValue: "", onChange: {[unowned self] sender in
                guard let textField = sender as? UITextField else { return }
                task?.careNotes = textField.text
            })
        ], toSection: .notes)

        let intervalType = task?.careSchedule?.recurrenceRule?.frequency
        let items = repeatFrequencyChoices.map { type in
            Item.pickerRow(title: type.rawValue.capitalized, isSelected: intervalType == type, tapAction: {[unowned self] in
                selectFrequency(type)
            })
        }
        dataSourceSnapshot.appendItems(items, toSection: .recurrenceFrequency)

        if dataSourceSnapshot.sectionIdentifiers.contains(.recurrenceValue) {
            if case .weekly = intervalType {
                let weekdayItems = makeWeekdayPicker()
                dataSourceSnapshot.appendItems(weekdayItems, toSection: .recurrenceValue)
            } else if case .monthly = intervalType {
                let dayItems = makeDayPicker()
                dataSourceSnapshot.appendItems(dayItems, toSection: .recurrenceValue)
            }
        }


        dataSourceSnapshot.appendItems([
            Item.button(context: .destructive, title: "Remove", image: UIImage(systemName: "trash"), onTap: {
                self.unassignTask()
            })
        ], toSection: .actions)

        dataSource.apply(dataSourceSnapshot)
    }

    private func selectFrequency(_ newValue: SproutRecurrenceFrequency) {
        guard let schedule = task?.careSchedule else { return }
        let oldType = schedule.recurrenceRule?.frequency
        // Prevent reloading if the values are the same
        guard oldType != newValue else { return }

        // Update the task interval parameters
        schedule.recurrenceRule?.recurrenceFrequency = newValue.rawValue
        switch schedule.recurrenceRule?.frequency {
        case .daily:
            schedule.recurrenceRule?.interval = 1
            schedule.recurrenceRule?.daysOfTheWeek = nil
            schedule.recurrenceRule?.daysOfTheMonth = nil
        case .weekly:
            schedule.recurrenceRule?.interval = 1
            schedule.recurrenceRule?.daysOfTheWeek = [1]
            schedule.recurrenceRule?.daysOfTheMonth = nil
        case .monthly:
            schedule.recurrenceRule?.interval = 1
            schedule.recurrenceRule?.daysOfTheWeek = nil
            schedule.recurrenceRule?.daysOfTheMonth = [1]

        default:
            // TODO: Update to delete recurrence rule for future use
            schedule.recurrenceRule?.interval = 1
            schedule.recurrenceRule?.daysOfTheWeek = nil
            schedule.recurrenceRule?.daysOfTheMonth = nil
        }

        // Update header without animation
        var headerSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        headerSnapshot.append([
            Item.largeHeader(title: task?.careCategory?.name, value: schedule.recurrenceRule?.intervalText(), image: task?.careCategory?.icon?.image, tintColor: task?.careCategory?.icon?.color)
        ])
        dataSource.apply(headerSnapshot, to: .header, animatingDifferences: false)

        // Update interval picker without animation
        var intervalSnapshot = dataSource.snapshot(for: .recurrenceFrequency)
        guard let itemToDeselect = intervalSnapshot.items.first(where: { $0.text == oldType?.rawValue.capitalized}),
              let itemToSelect = intervalSnapshot.items.first(where: { $0.text == newValue.rawValue.capitalized})
        else { return }

        intervalSnapshot.insert([
            Item.pickerRow(title: itemToDeselect.text, isSelected: !itemToDeselect.isOn, tapAction: itemToDeselect.tapAction)
        ], after: itemToDeselect)
        intervalSnapshot.delete([itemToDeselect])

        intervalSnapshot.insert([
            Item.pickerRow(title: itemToSelect.text, isSelected: !itemToSelect.isOn, tapAction: itemToSelect.tapAction)
        ], after: itemToSelect)
        intervalSnapshot.delete([itemToSelect])
        dataSource.apply(intervalSnapshot, to: .recurrenceFrequency, animatingDifferences: false)

        // Update the values picker for the appropriate interval

        var snapshot = dataSource.snapshot()
        switch schedule.recurrenceRule?.frequency {
        case .weekly:
            let weekdayItems = makeWeekdayPicker()
            if !snapshot.sectionIdentifiers.contains(.recurrenceValue) {
                snapshot.insertSections([.recurrenceValue], afterSection: .recurrenceFrequency)
            } else {
                let oldItems = snapshot.itemIdentifiers(inSection: .recurrenceValue)
                snapshot.deleteItems(oldItems)
            }
            snapshot.appendItems(weekdayItems, toSection: .recurrenceValue)
        case .monthly:
            let dayItems = makeDayPicker()
            if !snapshot.sectionIdentifiers.contains(.recurrenceValue) {
                snapshot.insertSections([.recurrenceValue], afterSection: .recurrenceFrequency)
            } else {
                let oldItems = snapshot.itemIdentifiers(inSection: .recurrenceValue)
                snapshot.deleteItems(oldItems)
            }
            snapshot.appendItems(dayItems, toSection: .recurrenceValue)
        default:
            if snapshot.sectionIdentifiers.contains(.recurrenceValue) {
                snapshot.deleteSections([.recurrenceValue])
            }
        }

        dataSource.apply(snapshot)
    }

    func setIntervalValue(to newValue: Set<Int>) {
        var valuesToChange: Set<Int> = []
        let rule = task?.careSchedule?.recurrenceRule

        if case .weekly = rule?.frequency {
            if let currentValues = rule?.daysOfTheWeek {
                valuesToChange = currentValues.symmetricDifference(newValue)
            }
            rule?.daysOfTheWeek = newValue

        } else if case .monthly = rule?.frequency {
            if let currentValues = rule?.daysOfTheMonth {
                valuesToChange = currentValues.symmetricDifference(newValue)
            }
            rule?.daysOfTheMonth = newValue
        }

        var headerSnapshot = dataSource.snapshot(for: .header)
        let newHeaderItem = Item.largeHeader(title: task?.careCategory?.name, value: rule?.intervalText(), image: task?.careCategory?.icon?.image, tintColor: task?.careCategory?.icon?.color)
        guard let oldItem = headerSnapshot.items.first(where: {$0.text == newHeaderItem.text}) else { return }
        headerSnapshot.insert([newHeaderItem], after: oldItem)
        headerSnapshot.delete([oldItem])

        dataSource.apply(headerSnapshot, to: .header, animatingDifferences: false)

        var recurrenceValuesSnapshot = dataSource.snapshot(for: .recurrenceValue)
        for value in valuesToChange {
            guard let oldItem = recurrenceValuesSnapshot.items.first(where: { $0.tag == value }) else { continue }
            var newItem = Item.circleButtonCell(text: oldItem.text, isSelected: !oldItem.isOn, tapAction: {
                self.repeatValueButtonTapped(value)
            })
            newItem.tag = value

            recurrenceValuesSnapshot.insert([newItem], after: oldItem)
            recurrenceValuesSnapshot.delete([oldItem])
        }

        dataSource.apply(recurrenceValuesSnapshot, to: .recurrenceValue, animatingDifferences: false)
    }

    func createSupplementaryHeaderRegistration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            guard let section = TaskEditorSection(rawValue: indexPath.section) else { return }
            var config = UIListContentConfiguration.largeGroupedHeader()
            config.text = section.headerTitle
            supplementaryView.contentConfiguration = config
            supplementaryView.contentView.backgroundColor = .systemGroupedBackground
        }
    }
}
