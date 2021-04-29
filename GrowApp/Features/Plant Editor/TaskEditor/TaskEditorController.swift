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
    let viewContext: NSManagedObjectContext
    var delegate: TaskEditorDelegate?
    let task: GHTask

    private lazy var imageView = UIImageView(image: UIImage(systemName: "circle"))
    private lazy var weekdayPicker: GridPicker = {
        let daySelectionChangedAction = UIAction { action in
            guard let sender = action.sender as? GridPicker else { return }
            let selection = sender.selectedIndices
            print(selection.sorted())
        }

        let picker = GridPicker()
        picker.addAction(daySelectionChangedAction, for: .valueChanged)
        picker.items = Calendar.current.veryShortStandaloneWeekdaySymbols.map {
            return "\($0)"
        }
        picker.itemsPerRow = 7
        return picker
    }()

    private lazy var dayPicker: GridPicker = {
        let daySelectionChangedAction = UIAction { action in
            guard let sender = action.sender as? GridPicker else { return }
            let selection = sender.selectedIndices
            print(selection.sorted())
        }

        let picker = GridPicker()
        picker.addAction(daySelectionChangedAction, for: .valueChanged)
        picker.items = Array(1...31).map {
            return "\($0)"
        }
        picker.itemsPerRow = 7
        return picker
    }()
    
    init(task: GHTask, viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.task = viewContext.object(with: task.objectID) as! GHTask
        if self.task.interval == nil {
            self.task.interval = GHTaskInterval(context: viewContext)
            self.task.interval?.type = 0
        }
        if self.task.nextCareDate == nil {
            self.task.nextCareDate = Date()
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

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
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 16, leading: 16, bottom: 0, trailing: 16)
                return section
            default:
                var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                config.headerMode = sectionKind.headerTitle != nil ? .supplementary : .none
                return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            }
        }

        return layout
    }

    @objc private func doneButtonPressed(_ sender: AnyObject) {
        delegate?.taskEditor(self, didUpdateTask: task)
        dismiss(animated: true)
    }

    @objc private func cancelButtonPressed(_ sender: AnyObject) {
        delegate?.taskEditorDidCancel(self)
        dismiss(animated: true)
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
            Item.largeHeader(title: task.taskType?.name, value: task.interval?.intervalText(), image: task.taskType?.icon?.image, tintColor: task.taskType?.icon?.color)
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
        let intervalType = task.interval?.frequency() ?? .none
        repeatsIntervalSnapshot.append([
            Item.pickerRow(title: "Never", isSelected: intervalType == .none, tapAction: {[unowned self] in
                selectInterval(.none)
            }),
            Item.pickerRow(title: "Daily", isSelected: intervalType == .daily, tapAction: {[unowned self] in
                selectInterval(.daily)
            }),
            Item.pickerRow(title: "Weekly", isSelected: intervalType == .weekly, tapAction: {[unowned self] in
                selectInterval(.weekly)
            }),
            Item.pickerRow(title: "Monthly", isSelected: intervalType == .monthly, tapAction: {[unowned self] in
                selectInterval(.monthly)
            })
        ])
        dataSource.apply(repeatsIntervalSnapshot, to: .repeatInterval)

        var repeatsValueSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        if case .weekly = task.interval?.frequency() {
            repeatsValueSnapshot.append([
                Item.customView(customView: weekdayPicker)
            ])
        } else if case .monthly = task.interval?.frequency() {
            repeatsValueSnapshot.append([
                Item.customView(customView: dayPicker)
            ])
        }

        dataSource.apply(repeatsValueSnapshot, to: .repeatValue)

        var actionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        actionSnapshot.append([
            Item.button(context: .destructive, title: "Remove", image: UIImage(systemName: "trash"), onTap: {
                print("Deleted")
            })
        ])
        dataSource.apply(actionSnapshot, to: .actions)
    }
    private func selectInterval(_ newValue: GHTaskIntervalType) {
        guard let interval = task.interval else { return }
        guard let oldType = GHTaskIntervalType(rawValue: Int(interval.type)) else { return }
        // Prevent reloading if the values are the same
        guard oldType != newValue else { return }

        // Update the task interval parameters
        task.interval?.type = Int16(newValue.rawValue)

        // Update header without animation
        var headerSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        headerSnapshot.append([
            Item.largeHeader(title: task.taskType?.name, value: task.interval?.intervalText(), image: task.taskType?.icon?.image, tintColor: task.taskType?.icon?.color)
        ])
        dataSource.apply(headerSnapshot, to: .header, animatingDifferences: false)

        // Update interval picker without animation
        var intervalSnapshot = dataSource.snapshot(for: .repeatInterval)
        let itemToDeselect = intervalSnapshot.items[oldType.rawValue]
        let itemToSelect = intervalSnapshot.items[newValue.rawValue]

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
        var valuesSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        if case .weekly = newValue {
            valuesSnapshot.append([
                Item.customView(customView: weekdayPicker)
            ])
        } else if case .monthly = newValue {
            valuesSnapshot.append([
                Item.customView(customView: dayPicker)
            ])
        }
        dataSource.apply(valuesSnapshot, to: .repeatValue, animatingDifferences: false)
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
