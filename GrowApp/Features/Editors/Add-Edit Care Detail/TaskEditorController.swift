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
    fileprivate typealias Section = ViewModel.Section
    fileprivate typealias Item = ViewModel.Item

    let dateFormatter = Utility.dateFormatter

    var storageProvider: StorageProvider
    var editingContext: NSManagedObjectContext { storageProvider.editingContext }

    var task: SproutCareTaskMO
    var delegate: TaskEditorDelegate?

    private let repeatFrequencyChoices = [
        "Daily",
        "Weekly",
        "Montly"
    ]

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    private lazy var imageView = UIImageView(image: UIImage(systemName: "circle"))

    private func makeWeekdayPicker() -> [Item] {
        let values = task.recurrenceDaysOfWeek ?? []
        let items: [Item] = Array(1...7).map { value in
            let title = Calendar.current.veryShortStandaloneWeekdaySymbols[value-1]
            let item = Item.circlePickerButton(text: title, isSelected: values.contains(value), tapAction: HashableClosure<Void>(handler: { [weak self] in
                self?.repeatValueButtonTapped(value)
            }))
            return item
        }

        return items
    }

    private func makeDayPicker() -> [Item] {
        let values = task.recurrenceDaysOfMonth ?? []
        let items: [Item] = Array(1...31).map { value in
            let title = String(value)
            let item = Item.circlePickerButton(text: title, isSelected: values.contains(value), tapAction: HashableClosure<Void>(handler: {
                self.repeatValueButtonTapped(value)
            }))
            return item
        }

        return items
    }

    //MARK: - Initializers
    init(task: SproutCareTaskMO, storageProvider: StorageProvider = AppDelegate.storageProvider) {
        self.task = task
        self.storageProvider = storageProvider

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Life Cycle
    override func loadView() {
        super.loadView()

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        dataSource = makeDataSource()

        updateUI()

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

    @objc private func repeatValueButtonTapped(_ value: Int) {
        // TODO: Add support for updating values

        var oldValues: Set<Int>
        let rule = task.recurrenceRule
        switch rule {
        case let .weekly(interval, weekdays) where interval == 1 && weekdays?.isEmpty == false:
            oldValues = weekdays!
        case let .monthly(interval, days) where interval == 1 && days?.isEmpty == false:
            oldValues = days!
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

// MARK: - Collection View Setup
extension TaskEditorController {
    // MARK: Layout
    func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
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
            case .recurrenceWeekly, .recurrenceMonthly:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/7), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1/7))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 24, bottom: 6, trailing: 24)
                section.decorationItems = [
                    NSCollectionLayoutDecorationItem.background(elementKind: RoundedRectBackgroundView.ElementKind)
                ]

            default:
                var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                config.headerMode = sectionKind.headerText != nil ? .supplementary : .none
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
        let circleButtonCellRegistration = makeCircleButtonCellRegistration()

        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {collectionView, indexPath, item in
            switch item {
            case .detailHeader:
                return collectionView.dequeueConfiguredReusableCell(using: detailHeaderRegistration, for: indexPath, item: item)
            case .pickerRow, .switchRow:
                return collectionView.dequeueConfiguredReusableCell(using: uiCollectionListCellRegistration, for: indexPath, item: item)
            case .circlePickerButton:
                return collectionView.dequeueConfiguredReusableCell(using: circleButtonCellRegistration, for: indexPath, item: item)
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

    private func applySnapshot() {
        var dataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        let visibleSections = ViewModel.Section.allCases.filter { sectionType in
            // Show the value picker only if the frequency is .weekly or .monthly
            switch sectionType {
            case .recurrenceFrequency:
                return task.hasSchedule == true
            case .recurrenceWeekly:
                guard case .weekly = task.recurrenceRule else { return false }
                return true
            case .recurrenceMonthly:
                guard case .monthly = task.recurrenceRule else { return false }
                return true
            default:
                return true
            }
        }
        dataSourceSnapshot.appendSections(visibleSections)
        dataSource.apply(dataSourceSnapshot)

        // Header Row
        if visibleSections.contains(.detailHeader) {
            applyDetailHeaderSnapshot()
        }

        if visibleSections.contains(.scheduleGeneral) {
            applyScheduleGeneralSnapshot(after: .detailHeader)
        }

        if visibleSections.contains(.recurrenceFrequency) {
            applyFrequencyPickerSnapshot(after: .scheduleGeneral)
        }

        if visibleSections.contains(.recurrenceWeekly) {
            applyWeekdayPickerSnapshot(after: .recurrenceFrequency)
        } else if visibleSections.contains(.recurrenceMonthly) {
            applyDayOfMonthPickerSnapshot(after: .recurrenceFrequency)
        }
    }

    private func applyDetailHeaderSnapshot(after section: Section? = nil) {
        // Get the current snapshots
        var currentSnapshot = dataSource.snapshot()
        var detailHeaderSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()

        if let section = section {
            let dataSourceContainsSection = currentSnapshot.sectionIdentifiers.contains(section)
            assert(dataSourceContainsSection, "Current dataSource snapshot does not contain the desired section. Add it before calling this method.")
            guard dataSourceContainsSection else { return }
        }

        // Apply the new items to the frequency snapshot
        let currentScheduleFormatter = Utility.careScheduleFormatter
        let scheduleValue = currentScheduleFormatter.string(for: task.schedule) ?? "No schedule"
        let valueIcon = task.schedule == nil ? "bell.slash" : "bell.fill"
        let item = Item.detailHeader(titleImage: task.taskTypeProperties?.icon, titleText: task.taskTypeProperties?.displayName, valueIcon: valueIcon, valueText: scheduleValue, tintColor: .systemBlue)

        detailHeaderSnapshot.append([item])

        if !currentSnapshot.sectionIdentifiers.contains(.recurrenceFrequency) {
            if let section = section {
                currentSnapshot.insertSections([.recurrenceFrequency], afterSection: section)
            } else {
                currentSnapshot.appendSections([.recurrenceFrequency])
            }
            dataSource.apply(currentSnapshot, animatingDifferences: false)
        }

        dataSource.apply(detailHeaderSnapshot, to: .detailHeader, animatingDifferences: false)
    }

    private func applyScheduleGeneralSnapshot(after section: Section? = nil) {
        // Get the current snapshots
        var currentSnapshot = dataSource.snapshot()
        var scheduleGeneralSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()

        if let section = section {
            let dataSourceContainsSection = currentSnapshot.sectionIdentifiers.contains(section)
            assert(dataSourceContainsSection, "Current dataSource snapshot does not contain the desired section. Add it before calling this method.")
            guard dataSourceContainsSection else { return }
        }

        scheduleGeneralSnapshot.append([
            .switchRow(icon: nil, title: "Reminders", isEnabled: task.hasSchedule, tapAction: HashableClosure<Bool>(handler: {[weak self] newValue in
                self?.setCareScheduleEnabled(to: newValue)
            }))
        ])

        if !currentSnapshot.sectionIdentifiers.contains(.scheduleGeneral) {
            if let section = section {
                currentSnapshot.insertSections([.scheduleGeneral], afterSection: section)
            } else {
                currentSnapshot.appendSections([.scheduleGeneral])
            }
            dataSource.apply(currentSnapshot, animatingDifferences: false)
        }

        dataSource.apply(scheduleGeneralSnapshot, to: .scheduleGeneral, animatingDifferences: false)
    }

    private func applyFrequencyPickerSnapshot(after section: Section? = nil) {
        // Get the current snapshots
        var currentSnapshot = dataSource.snapshot()
        var frequencyPickerSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()

        if let section = section {
            let dataSourceContainsSection = currentSnapshot.sectionIdentifiers.contains(section)
            assert(dataSourceContainsSection, "Current dataSource snapshot does not contain the desired section. Add it before calling this method.")
            guard dataSourceContainsSection else { return }
        }

        // Apply the new items to the frequency snapshot
        let intervalType = task.recurrenceFrequency ?? ""
        let items: [Item] = repeatFrequencyChoices.map { type in
            .pickerRow(image: nil, title: type, isSelected: type.caseInsensitiveCompare(intervalType) == .orderedSame, tapAction: HashableClosure<Void>(handler: { [weak self] in
                self?.selectFrequency(type)
            }))
        }
        frequencyPickerSnapshot.append(items)

        if !currentSnapshot.sectionIdentifiers.contains(.recurrenceFrequency) {
            if let section = section {
                currentSnapshot.insertSections([.recurrenceFrequency], afterSection: section)
            } else {
                currentSnapshot.appendSections([.recurrenceFrequency])
            }
            dataSource.apply(currentSnapshot, animatingDifferences: false)
        }

        dataSource.apply(frequencyPickerSnapshot, to: .recurrenceFrequency, animatingDifferences: false)
    }

    private func applyWeekdayPickerSnapshot(after section: Section? = nil) {
        // Get the current snapshots
        var currentSnapshot = dataSource.snapshot()
        var weekdayPickerSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()

        if let section = section {
            let dataSourceContainsSection = currentSnapshot.sectionIdentifiers.contains(section)
            assert(dataSourceContainsSection, "Current dataSource snapshot does not contain the desired section. Add it before calling this method.")
            guard dataSourceContainsSection else { return }
        }

        // Apply the new items to the weekday picker snapshot
        let weekdayItems = makeWeekdayPicker()
        weekdayPickerSnapshot.append(weekdayItems)

        if !currentSnapshot.sectionIdentifiers.contains(.recurrenceWeekly) {
            if let section = section {
                currentSnapshot.insertSections([.recurrenceWeekly], afterSection: section)
            } else {
                currentSnapshot.appendSections([.recurrenceWeekly])
            }
            dataSource.apply(currentSnapshot, animatingDifferences: false)
        }

        dataSource.apply(weekdayPickerSnapshot, to: .recurrenceWeekly, animatingDifferences: false)
    }

    private func applyDayOfMonthPickerSnapshot(after section: Section? = nil) {
        // Get the current snapshots
        var currentSnapshot = dataSource.snapshot()
        var dayOfMonthPickerSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()

        if let section = section {
            let dataSourceContainsSection = currentSnapshot.sectionIdentifiers.contains(section)
            assert(dataSourceContainsSection, "Current dataSource snapshot does not contain the desired section. Add it before calling this method.")
            guard dataSourceContainsSection else { return }
        }

        // Apply the new items to the weekday picker snapshot
        let dayPickerItems = makeDayPicker()
        dayOfMonthPickerSnapshot.append(dayPickerItems)

        if !currentSnapshot.sectionIdentifiers.contains(.recurrenceMonthly) {
            if let section = section {
                currentSnapshot.insertSections([.recurrenceMonthly], afterSection: section)
            } else {
                currentSnapshot.appendSections([.recurrenceMonthly])
            }
            dataSource.apply(currentSnapshot, animatingDifferences: false)
        }

        dataSource.apply(dayOfMonthPickerSnapshot, to: .recurrenceMonthly, animatingDifferences: false)
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

        updateUI()
    }

    private func selectFrequency(_ newValue: String) {
        guard newValue.caseInsensitiveCompare(task.recurrenceFrequency ?? "") != .orderedSame else { return }

        // Update the task interval parameters
        switch newValue {
        case "Daily":
            task.schedule = .init(startDate: Date(), recurrenceRule: .daily(1))
        case "Weekly":
            task.schedule = .init(startDate: Date(), recurrenceRule: .weekly(1, [1]))
        case "Monthly":
            task.schedule = .init(startDate: Date(), recurrenceRule: .monthly(1, [1]))
        default:
            print("Unknown frequency value: \(newValue)")
            task.schedule = nil
        }

        delegate?.taskEditor(self, didUpdateTask: task)
        updateUI()
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
        updateUI()
    }
}

// MARK: - Collection View Delegate
extension TaskEditorController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let item = dataSource.itemIdentifier(for: indexPath)
        switch item {
        case .pickerRow, .circlePickerButton:
            return true
        default:
            return false
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource.itemIdentifier(for: indexPath)
        switch item {
        case .pickerRow(_, _, _, let tapAction):
            tapAction.handler(Void())
        case .circlePickerButton(_, _, let tapAction):
            tapAction.handler(Void())
        default:
            break
        }

        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: - Cell Registration
private extension TaskEditorController {
    func updateUI() {
        applySnapshot()
    }

    func makeDetailHeaderRegistration() -> UICollectionView.CellRegistration<LargeHeaderCell, Item> {
        UICollectionView.CellRegistration<LargeHeaderCell, Item> { cell, indexPath, item in
            guard case let .detailHeader(titleImage, titleText, valueIcon, valueText, tintColor) = item else { return }
            cell.titleImage = titleImage
            cell.titleText = titleText
            cell.valueIcon = valueIcon
            cell.valueText = valueText
            cell.tintColor = tintColor

            cell.layer.cornerRadius = 10
            cell.clipsToBounds = true
        }
    }

    func makeUICollectionViewListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            switch item {
            case let .pickerRow(image, title, isSelected, _):
                var config = UIListContentConfiguration.valueCell()
                config.image = image
                config.text = title

                cell.contentConfiguration = config
                cell.accessories = isSelected ? [.checkmark()] : []
            case let.switchRow(icon, title, isEnabled, tapAction):
                var config = UIListContentConfiguration.valueCell()
                if let icon = icon {
                    config.image = UIImage(named: icon) ?? UIImage(systemName: icon)
                }
                config.text = title

                cell.contentConfiguration = config

                let action = UIAction { action in
                    let newState = (action.sender as? UISwitch)?.isOn ?? false
                    tapAction.handler(newState)
                }

                cell.accessories = [
                    .toggleAccessory(isOn: isEnabled, action: action)
                ]


            default:
                break
            }
        }
    }

    func makeCircleButtonCellRegistration() -> UICollectionView.CellRegistration<SproutButtonCell, Item> {
        let tintColor = view.tintColor

        return UICollectionView.CellRegistration<SproutButtonCell, Item> { cell, indexPath, item in
            switch item {
            case let .circlePickerButton(text, isSelected, _):
                cell.title = text
                cell.isSelected = isSelected
                cell.displayMode = .plain
                cell.tintColor = isSelected ? tintColor : .systemGray
                cell.layer.cornerRadius = cell.bounds.height/2
                cell.clipsToBounds = true
            default:
                break
            }
        }
    }

    func createSupplementaryHeaderRegistration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            var config = UIListContentConfiguration.largeGroupedHeader()
            config.text = section.headerText
            supplementaryView.contentConfiguration = config
            supplementaryView.contentView.backgroundColor = .systemGroupedBackground
        }
    }
}

// MARK: - Data Source View Model
private extension TaskEditorController {
    enum ViewModel {
        enum Section: CaseIterable {
            case detailHeader
            //            case lastCareDate
            case scheduleGeneral
            case recurrenceFrequency
            case recurrenceDaily
            case recurrenceWeekly
            case recurrenceMonthly

            var headerText: String? {
                switch self {
                //                case .lastCareDate:
                //                    return "Last Care Date"
                case .recurrenceFrequency:
                    return "Repeats"
                case .recurrenceWeekly, .recurrenceMonthly:
                    return "On these days"
                default:
                    return nil
                }
            }

            var footerText: String? {
                switch self {
                default:
                    return nil
                }
            }
        }

        enum Item: Hashable {
            case detailHeader(titleImage: UIImage?, titleText: String?, valueIcon: String?, valueText: String?, tintColor: UIColor?)
            case pickerRow(image: UIImage?, title: String?, isSelected: Bool, tapAction: HashableClosure<Void>)
            case switchRow(icon: String?, title: String?, isEnabled: Bool, tapAction: HashableClosure<Bool>)
            case circlePickerButton(text: String, isSelected: Bool, tapAction: HashableClosure<Void>)

            enum CellAccessory {
                case checkmark

                var uiCellAccessory: UICellAccessory {
                    switch self {
                    case .checkmark:
                        return UICellAccessory.checkmark()
                    }
                }
            }
        }
    }
}
