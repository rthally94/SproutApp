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
    let task: GHTask

    private lazy var imageView = UIImageView(image: UIImage(systemName: "circle"))
    private lazy var weekdayPicker: ImagePicker = {
        let action = UIAction { action in
            guard let sender = action.sender as? ImagePicker else { return }
            let weekdays = sender.selectedIndices.map {
                Calendar.current.veryShortStandaloneWeekdaySymbols[$0]
            }
            print(weekdays)
        }

        let picker = ImagePicker(frame: .zero, primaryAction: action)
        picker.images = Calendar.current.veryShortStandaloneWeekdaySymbols.compactMap {
            UIImage(systemName: "\($0.lowercased()).circle")
        }
        return picker
    }()
    
    init(task: GHTask, viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.task = viewContext.object(with: task.objectID) as! GHTask
        if task.interval == nil {
            task.interval = GHTaskInterval(context: viewContext)
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
        updateDataSource()
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
}

extension TaskEditorController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let item = dataSource.itemIdentifier(for: indexPath)
        return item?.isNavigable ?? false
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource.itemIdentifier(for: indexPath)
        item?.action?(self)
    }
    
//    private func makeValueCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, FormItem> {
//        UICollectionView.CellRegistration<UICollectionViewListCell, FormItem> { cell, indexPath, item in
//            var config = UIListContentConfiguration.valueCell()
//            if case let .valueListCell(image, text, secondaryText) = item {
//                config.image = image
//                config.text = text
//                config.secondaryText = secondaryText
//            }
//            cell.contentConfiguration = config
//        }
//    }
//
//    private func makeToggleRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, FormItem> {
//        UICollectionView.CellRegistration<UICollectionViewListCell, FormItem> { cell, indexPath, item in
//            if case let .toggle(image, text, secondaryText, isOn, action) = item {
//                var config = UIListContentConfiguration.subtitleCell()
//                config.image = image
//                config.text = text
//                config.secondaryText = secondaryText
//
//                config.directionalLayoutMargins = .init(top: 10, leading: 0, bottom: 10, trailing: 0)
//
//                cell.contentConfiguration = config
//
//                cell.accessories = [
//                    .toggleAccessory(isOn: isOn, action: action)
//                ]
//            } else if case let .outlineToggle(image, text, secondaryText, isOn) = item {
//                var config = UIListContentConfiguration.subtitleCell()
//                config.image = image
//                config.text = text
//                config.secondaryText = secondaryText
//
//                config.directionalLayoutMargins = .init(top: 10, leading: 0, bottom: 10, trailing: 0)
//
//                cell.contentConfiguration = config
//
//                let outlineAction = UIAction { [unowned self] action in
//                    guard let toggle = action.sender as? UISwitch else { return }
//                    print(toggle.isOn ? "Yes" : "No")
//
//                    if toggle.isOn {
//                        updateDatePickerHeader(with: Date())
//                    } else {
//                        hideDatePicker()
//                    }
//                }
//
//                cell.accessories = [
//                    .toggleAccessory(isOn: isOn, action: outlineAction)
//                ]
//            }
//        }
//    }
//
//    private func makeDatePickerRegistration() -> UICollectionView.CellRegistration<DatePickerListCell, FormItem> {
//        UICollectionView.CellRegistration<DatePickerListCell, FormItem> { cell, indexPath, item in
//            guard case let .datePicker(date, action) = item else { return }
//            cell.updateWith(date: date ?? Date(), action: action)
//        }
//    }
}

extension TaskEditorController {
    func updateUI() {
        updateDataSource()
    }
    
    private func updateDataSource() {
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
        repeatsIntervalSnapshot.append([
            Item.pickerRow(title: "Never", isSelected: true),
            Item.pickerRow(title: "Daily", isSelected: false),
            Item.pickerRow(title: "Weekly", isSelected: false),
            Item.pickerRow(title: "Monthly", isSelected: false)
        ])
        dataSource.apply(repeatsIntervalSnapshot, to: .repeatInterval)

//        if task.interval?.frequency() == GHTaskIntervalType.weekly {
            var repeatsValueSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
            repeatsValueSnapshot.append([
                Item.customView(customView: weekdayPicker)
            ])
            dataSource.apply(repeatsValueSnapshot, to: .repeatValue)
//        }

        var actionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        actionSnapshot.append([
            Item.button(context: .destructive, title: "Remove", image: UIImage(systemName: "trash"), onTap: {[unowned self] sender in
                print("Deleted")
            })
        ])
        dataSource.apply(actionSnapshot, to: .actions)
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
        // Type Selection
//        var typeSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
//        typeSnapshot.append([
//            FormItem.valueListCell(image: nil, text: "Type", secondaryText: task.taskType?.name ?? "Select Type")
//        ])
//        dataSource.apply(typeSnapshot, to: .type)
//
//        // Starting Date/Repeats
//        let date = task.interval?.startDate
//
//        var datePickerSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
//
//        let isOn = task.interval?.startDate != nil
//        let dateString: String? = {
//            if let startDate = task.interval?.startDate {
//                return dateFormatter.string(from: startDate)
//            } else {
//                return nil
//            }
//        }()
//
//        let header = FormItem.outlineToggle(image: UIImage(systemName: "calendar"), text: "Date", secondaryText: dateString, isOn: isOn)
//        datePickerSnapshot.append([
//            header
//        ])
//
//        let dateChangedAction = UIAction { [unowned self] action in
//            guard let datePicker = action.sender as? UIDatePicker else { return }
//            let date = datePicker.date
//            self.task.interval?.startDate = date
//            self.updateDatePickerHeader(with: date)
//        }
//
//        let picker = FormItem.datePicker(date, dateChangedAction)
//        datePickerSnapshot.append([picker], to: header)
//
//        dataSource.apply(datePickerSnapshot, to: .interval)
}
