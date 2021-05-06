//
//  TaskIntervalEditorController.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/8/21.
//

import CoreData
import UIKit

enum TaskEditorSection: Int, Hashable, CaseIterable {
    case header, notes, repeatInterval, repeatValue, actions

    var headerTitle: String? {
        switch self {
        case .notes:
            return "Notes"
        case .repeatInterval:
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
    var task: GHTask?

    private let repeatFrequencyChoices = [
        GHTaskIntervalType.never,
        GHTaskIntervalType.daily,
        GHTaskIntervalType.weekly,
        GHTaskIntervalType.monthly
    ]

    private lazy var imageView = UIImageView(image: UIImage(systemName: "circle"))

    private func makeWeekdayPicker() -> [Item] {
        guard let values = task?.interval?.repeatsValues else { return [] }
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
        guard let values = task?.interval?.componentsArray else { return [] }
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
        assert(task?.interval != nil, "TaskEditorViewController --- Task Interval cannot be \"nil\". Set the property before presenting.")

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
            case .repeatValue:
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
        var intervalValues = task?.interval?.repeatsValues ?? []
        if intervalValues.contains(value) == true {
            intervalValues.remove(value)
        } else {
            intervalValues.insert(value)
        }
        setIntervalValue(to: intervalValues)
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
        dataSourceSnapshot.appendSections(TaskEditorSection.allCases)
        dataSource.apply(dataSourceSnapshot)
        
        // Header Row
        var headerSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        headerSnapshot.append([
            Item.largeHeader(title: task?.taskType?.name, value: task?.interval?.intervalText(), image: task?.taskType?.icon?.image, tintColor: task?.taskType?.icon?.color)
        ])
        dataSource.apply(headerSnapshot, to: .header)

        var notesSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        notesSnapshot.append([
            Item.textField(placeholder: "Add Note", initialValue: "", onChange: { sender in
                guard let textField = sender as? UITextField else { return }
                print(textField.text ?? "Unknown Text")
            })
        ])
        dataSource.apply(notesSnapshot, to: .notes)

        var repeatsIntervalSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        let intervalType = task?.interval?.wrappedFrequency

        let items = repeatFrequencyChoices.map { type in
            Item.pickerRow(title: type.rawValue.capitalized, isSelected: intervalType == type, tapAction: {[unowned self] in
                selectInterval(type)
            })
        }
        repeatsIntervalSnapshot.append(items)
        dataSource.apply(repeatsIntervalSnapshot, to: .repeatInterval)

        var repeatsValueSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        if case .weekly = task?.interval?.wrappedFrequency {
            repeatsValueSnapshot.append(makeWeekdayPicker())

        } else if case .monthly = task?.interval?.wrappedFrequency {
            repeatsValueSnapshot.append(makeDayPicker())
        }

        dataSource.apply(repeatsValueSnapshot, to: .repeatValue)

        var actionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        actionSnapshot.append([
            Item.button(context: .destructive, title: "Remove", image: UIImage(systemName: "trash"), onTap: {
                self.unassignTask()
            })
        ])
        dataSource.apply(actionSnapshot, to: .actions)
    }

    private func selectInterval(_ newValue: GHTaskIntervalType) {
        guard let interval = task?.interval else { return }
        let oldType = interval.wrappedFrequency
        // Prevent reloading if the values are the same
        guard oldType != newValue else { return }

        // Update the task interval parameters
        interval.repeatsFrequency = newValue.rawValue
        interval.repeatsValues = []

        // Update header without animation
        var headerSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        headerSnapshot.append([
            Item.largeHeader(title: task?.taskType?.name, value: task?.interval?.intervalText(), image: task?.taskType?.icon?.image, tintColor: task?.taskType?.icon?.color)
        ])
        dataSource.apply(headerSnapshot, to: .header, animatingDifferences: false)

        // Update interval picker without animation
        var intervalSnapshot = dataSource.snapshot(for: .repeatInterval)
        guard let itemToDeselect = intervalSnapshot.items.first(where: { $0.text == oldType.rawValue.capitalized}),
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
        dataSource.apply(intervalSnapshot, to: .repeatInterval, animatingDifferences: false)

        // Update the values picker for the appropriate interval
        var repeatsValueSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        if case .weekly = task?.interval?.wrappedFrequency {
            repeatsValueSnapshot.append(makeWeekdayPicker())

        } else if case .monthly = task?.interval?.wrappedFrequency {
            repeatsValueSnapshot.append(makeDayPicker())
        }

        dataSource.apply(repeatsValueSnapshot, to: .repeatValue, animatingDifferences: false)
    }

    func setIntervalValue(to newValue: Set<Int>) {
        var valuesToChange: Set<Int> = []
        if let currentValues = task?.interval?.repeatsValues {
            valuesToChange = currentValues.symmetricDifference(newValue)
        }

        task?.interval?.repeatsValues = newValue

        var headerSnapshot = dataSource.snapshot(for: .header)
        let newHeaderItem = Item.largeHeader(title: task?.taskType?.name, value: task?.interval?.intervalText(), image: task?.taskType?.icon?.image, tintColor: task?.taskType?.icon?.color)
        guard let oldItem = headerSnapshot.items.first(where: {$0.text == newHeaderItem.text}) else { return }
        headerSnapshot.insert([newHeaderItem], after: oldItem)
        headerSnapshot.delete([oldItem])

        dataSource.apply(headerSnapshot, to: .header, animatingDifferences: false)

        var repeatsValueSnapshot = dataSource.snapshot(for: .repeatValue)
        for value in valuesToChange {
            guard let oldItem = repeatsValueSnapshot.items.first(where: { $0.tag == value }) else { continue }
            var newItem = Item.circleButtonCell(text: oldItem.text, isSelected: !oldItem.isOn, tapAction: {
                self.repeatValueButtonTapped(value)
            })
            newItem.tag = value

            repeatsValueSnapshot.insert([newItem], after: oldItem)
            repeatsValueSnapshot.delete([oldItem])
        }

        dataSource.apply(repeatsValueSnapshot, to: .repeatValue, animatingDifferences: false)
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
