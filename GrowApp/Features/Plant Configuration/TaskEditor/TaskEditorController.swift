//
//  TaskIntervalEditorController.swift
//  GrowApp
//
//  Created by Ryan Thally on 4/8/21.
//

import CoreData
import UIKit

class TaskEditorController: UIViewController {
    let dateFormatter = Utility.dateFormatter
    let viewContext: NSManagedObjectContext
    let task: GHTask
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, FormItem>!
    
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
    
    private enum Section: Hashable, CaseIterable {
        case header, type, interval, notes, actions
    }
    
    private enum FormItem: Hashable {
        case subtitleListCell(image: UIImage?, text: String?, secondaryText: String?)
        case valueListCell(image: UIImage?, text: String?, secondaryText: String?)
        case toggle(image: UIImage?, text: String?, secondaryText: String?, isOn: Bool, action: UIAction)
        case outlineToggle(image: UIImage?, text: String?, secondaryText: String?, isOn: Bool)
        case datePicker(Date?, UIAction)
    }
    
    // MARK: - View Life Cycle
    override func loadView() {
        super.loadView()
        
        configureHiearchy()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateDataSource()
    }
}

extension TaskEditorController {
    private func configureHiearchy() {
        configureCollectionView()
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.pinToBoundsOf(view)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.delegate = self
        dataSource = makeDataSource()
    }
    
    private func makeLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, FormItem> {
        let toggleRegistration = makeToggleRegistration()
        let valueRegistration = makeValueCellRegistration()
        let datePickerRegistration = makeDatePickerRegistration()
        
        let dataSource = UICollectionViewDiffableDataSource<Section, FormItem>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .toggle, .outlineToggle:
                return collectionView.dequeueConfiguredReusableCell(using: toggleRegistration, for: indexPath, item: item)
            case .datePicker:
                return collectionView.dequeueConfiguredReusableCell(using: datePickerRegistration, for: indexPath, item: item)
            case .valueListCell:
                return collectionView.dequeueConfiguredReusableCell(using: valueRegistration, for: indexPath, item: item)
            default:
                return collectionView.dequeueConfiguredReusableCell(using: valueRegistration, for: indexPath, item: item)
            }
        }
        
        return dataSource
    }
    
    private func makeValueCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, FormItem> {
        UICollectionView.CellRegistration<UICollectionViewListCell, FormItem> { cell, indexPath, item in
            var config = UIListContentConfiguration.valueCell()
            if case let .valueListCell(image, text, secondaryText) = item {
                config.image = image
                config.text = text
                config.secondaryText = secondaryText
            }
            cell.contentConfiguration = config
        }
    }
    
    private func makeToggleRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, FormItem> {
        UICollectionView.CellRegistration<UICollectionViewListCell, FormItem> { cell, indexPath, item in
            if case let .toggle(image, text, secondaryText, isOn, action) = item {
                var config = UIListContentConfiguration.subtitleCell()
                config.image = image
                config.text = text
                config.secondaryText = secondaryText
                
                config.directionalLayoutMargins = .init(top: 10, leading: 0, bottom: 10, trailing: 0)
                
                cell.contentConfiguration = config
                
                cell.accessories = [
                    .toggleAccessory(isOn: isOn, action: action)
                ]
            } else if case let .outlineToggle(image, text, secondaryText, isOn) = item {
                var config = UIListContentConfiguration.subtitleCell()
                config.image = image
                config.text = text
                config.secondaryText = secondaryText
                
                config.directionalLayoutMargins = .init(top: 10, leading: 0, bottom: 10, trailing: 0)
                
                cell.contentConfiguration = config
                
                let outlineAction = UIAction { [unowned self] action in
                    guard let toggle = action.sender as? UISwitch else { return }
                    print(toggle.isOn ? "Yes" : "No")
                    
                    if toggle.isOn {
                        updateDatePickerHeader(with: Date())
                    } else {
                        hideDatePicker()
                    }
                }
                
                cell.accessories = [
                    .toggleAccessory(isOn: isOn, action: outlineAction)
                ]
            }
        }
    }
    
    private func makeDatePickerRegistration() -> UICollectionView.CellRegistration<DatePickerListCell, FormItem> {
        UICollectionView.CellRegistration<DatePickerListCell, FormItem> { cell, indexPath, item in
            guard case let .datePicker(date, action) = item else { return }
            cell.updateWith(date: date ?? Date(), action: action)
        }
    }
}

extension TaskEditorController {
    func updateUI() {
        updateDataSource()
    }
    
    private func updateDataSource() {
        var dataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, FormItem>()
        dataSourceSnapshot.appendSections(Section.allCases)
        dataSource.apply(dataSourceSnapshot)
        
        // Header Row
        var headerSnapshot = NSDiffableDataSourceSectionSnapshot<FormItem>()
        headerSnapshot.append([
            FormItem.valueListCell(image: task.taskType?.icon?.image, text: task.taskType?.name, secondaryText: nil)
        ])
        dataSource.apply(headerSnapshot, to: .header)
        
        // Type Selection
        var typeSnapshot = NSDiffableDataSourceSectionSnapshot<FormItem>()
        typeSnapshot.append([
            FormItem.valueListCell(image: nil, text: "Type", secondaryText: task.taskType?.name ?? "Select Type")
        ])
        dataSource.apply(typeSnapshot, to: .type)
        
        // Starting Date/Repeats
        let date = task.interval?.startDate
        
        var datePickerSnapshot = NSDiffableDataSourceSectionSnapshot<FormItem>()
        
        let isOn = task.interval?.startDate != nil
        let dateString: String? = {
            if let startDate = task.interval?.startDate {
                return dateFormatter.string(from: startDate)
            } else {
                return nil
            }
        }()
        
        let header = FormItem.outlineToggle(image: UIImage(systemName: "calendar"), text: "Date", secondaryText: dateString, isOn: isOn)
        datePickerSnapshot.append([
            header
        ])
        
        let dateChangedAction = UIAction { [unowned self] action in
            guard let datePicker = action.sender as? UIDatePicker else { return }
            let date = datePicker.date
            self.task.interval?.startDate = date
            self.updateDatePickerHeader(with: date)
        }
        
        let picker = FormItem.datePicker(date, dateChangedAction)
        datePickerSnapshot.append([picker], to: header)
        
        dataSource.apply(datePickerSnapshot, to: .interval)
    }
    
    private func updateDatePickerHeader(with date: Date?, animated: Bool = true) {
        let sectionSnapshot = dataSource.snapshot(for: .interval)
        
        guard let oldHeaderItem = sectionSnapshot.rootItems.first,
              let datePickerItem = sectionSnapshot.snapshot(of: oldHeaderItem).items.first
        else { return }
        
        // Setup helper properties
        var datePickerIsVisible: Bool {
            return date != nil
        }
        
        let dateString: String? = {
            if let date = date {
                return dateFormatter.string(from: date)
            } else {
                return nil
            }
        }()
        
        // Create new header with updated date
        let newHeaderItem = FormItem.outlineToggle(image: UIImage(systemName: "calendar"), text: "Date", secondaryText: dateString, isOn: true)
        
        // Replace the existing header
        var newSectionSnapshot = sectionSnapshot
        newSectionSnapshot.insert([newHeaderItem], before: oldHeaderItem)
        newSectionSnapshot.delete([oldHeaderItem])
        
        // Add and show the date picker
        newSectionSnapshot.append([datePickerItem], to: newHeaderItem)
        newSectionSnapshot.expand([newHeaderItem])
        
        dataSource.apply(newSectionSnapshot, to: .interval, animatingDifferences: true)
    }
    
    private func hideDatePicker(animated: Bool = true) {
        let sectionSnapshot = dataSource.snapshot(for: .interval)
        
        guard let oldHeaderItem = sectionSnapshot.rootItems.first,
              let datePickerItem = sectionSnapshot.snapshot(of: oldHeaderItem).items.first
        else { return }
        
        // Create new header with updated date
        let newHeaderItem = FormItem.outlineToggle(image: UIImage(systemName: "calendar"), text: "Date", secondaryText: nil, isOn: false)
        
        // Replace the existing header
        var newSectionSnapshot = sectionSnapshot
        newSectionSnapshot.insert([newHeaderItem], before: oldHeaderItem)
        newSectionSnapshot.delete([oldHeaderItem])
        
        // Add the date picker
        newSectionSnapshot.append([datePickerItem], to: newHeaderItem)
//        newSectionSnapshot.expand([newHeaderItem])
        
        dataSource.apply(newSectionSnapshot, to: .interval, animatingDifferences: animated)
    }
}

extension TaskEditorController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}
