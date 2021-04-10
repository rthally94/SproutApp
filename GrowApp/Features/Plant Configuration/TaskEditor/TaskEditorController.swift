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
    private var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>!
    
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
    
    private enum DatePickerItem: Hashable {
        case header(image: UIImage?, text: String?, secondaryText: String?, isOn: Bool, action: UIAction)
        case picker(Date?, UIAction)
    }
    
    private enum ListItem: Hashable {
        case subtitle(image: UIImage?, text: String?, secondaryText: String?)
        case value(image: UIImage?, text: String?, secondaryText: String?)
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
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.delegate = self
        dataSource = makeDataSource()
    }
    
    private func makeLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, AnyHashable> {
        let toggleRegistration = makeToggleRegistration()
        let valueRegistration = makeValueCellRegistration()
        let datePickerRegistration = makeDatePickerRegistration()
        
        let dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>(collectionView: collectionView) { collectionView, indexPath, item in
            if let row = item as? DatePickerItem {
                switch row {
                case .header:
                    return collectionView.dequeueConfiguredReusableCell(using: toggleRegistration, for: indexPath, item: row)
                case .picker:
                    return collectionView.dequeueConfiguredReusableCell(using: datePickerRegistration, for: indexPath, item: row)
                }
            } else if let row = item as? ListItem {
                switch row {
                case .value:
                    return collectionView.dequeueConfiguredReusableCell(using: valueRegistration, for: indexPath, item: row)
                default:
                    return collectionView.dequeueConfiguredReusableCell(using: valueRegistration, for: indexPath, item: row)
                }
            } else {
                fatalError("Unknown Row Item Type")
            }
        }
        
        return dataSource
    }
    
    private func updateDataSource() {
        var dataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        dataSourceSnapshot.appendSections(Section.allCases)
        dataSource.apply(dataSourceSnapshot)
        
        // Header Row
        var headerSnapshot = NSDiffableDataSourceSectionSnapshot<AnyHashable>()
        headerSnapshot.append([
            ListItem.value(image: task.taskType?.icon?.image, text: task.taskType?.name, secondaryText: nil)
        ])
        dataSource.apply(headerSnapshot, to: .header)
        
        // Type Selection
        var typeSnapshot = NSDiffableDataSourceSectionSnapshot<AnyHashable>()
        typeSnapshot.append([
            ListItem.value(image: nil, text: "Type", secondaryText: task.taskType?.name ?? "Select Type")
        ])
        dataSource.apply(typeSnapshot, to: .type)
        
        // Starting Date/Repeats
        let date = task.interval?.startDate
        
        var datePickerSnapshot = NSDiffableDataSourceSectionSnapshot<AnyHashable>()
        
        let isOn = task.interval?.startDate != nil
        let dateString: String? = {
            if let startDate = task.interval?.startDate {
                return dateFormatter.string(from: startDate)
            } else {
                return nil
            }
        }()
        let toggleAction = UIAction { [unowned self] action in
            guard let toggle = action.sender as? UISwitch else { return }
            if toggle.isOn {
                self.task.interval?.startDate = Date()
            } else {
                self.task.interval?.startDate = nil
            }
            
            self.reloadDateHeader(with: task.interval?.startDate)
        }
        
        let header = DatePickerItem.header(image: UIImage(systemName: "calndar"), text: "Date", secondaryText: dateString, isOn: isOn, action: toggleAction)
        datePickerSnapshot.append([
            header
        ])
        
        let dateChangedAction = UIAction { [unowned self] action in
            guard let datePicker = action.sender as? UIDatePicker else { return }
            self.task.interval?.startDate = datePicker.date
//            reloadDateHeader(with: datePicker.date)
        }
        
        let picker = DatePickerItem.picker(date, dateChangedAction)
        datePickerSnapshot.append([picker], to: header)
        
        dataSource.apply(datePickerSnapshot, to: .interval)
    }
    
    private func makeValueCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, ListItem> {
        UICollectionView.CellRegistration<UICollectionViewListCell, ListItem> { cell, indexPath, item in
            var config = UIListContentConfiguration.valueCell()
            if case let .value(image, text, secondaryText) = item {
                config.image = image
                config.text = text
                config.secondaryText = secondaryText
            }
            cell.contentConfiguration = config
        }
    }
    
    private func makeToggleRegistration() -> UICollectionView.CellRegistration<ToggleListCell, DatePickerItem> {
        UICollectionView.CellRegistration<ToggleListCell, DatePickerItem> { cell, indexPath, item in
            guard case let .header(image, text, secondaryText, isOn, action) = item else { return }
            cell.updateWith(image: image, text: text, secondaryText: secondaryText, isEnabled: isOn, action: action)
        }
    }
    
    private func makeDatePickerRegistration() -> UICollectionView.CellRegistration<DatePickerListCell, DatePickerItem> {
        UICollectionView.CellRegistration<DatePickerListCell, DatePickerItem> { cell, indexPath, item in
            guard case let .picker(date, action) = item else { return }
            cell.updateWith(date: date ?? Date(), action: action)
        }
    }
}

extension TaskEditorController {
    private func configureHiearchy() {
        configureCollectionView()
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.pinToBoundsOf(view)
    }
    
    func updateUI() {
        updateDataSource()
    }
    
    private func reloadDateHeader(with date: Date?) {
        let sectionSnapshot = dataSource.snapshot(for: .interval)
        
        guard let oldHeaderItem = sectionSnapshot.rootItems.first,
              let datePickerItem = sectionSnapshot.snapshot(of: oldHeaderItem).items.first
        else { return }
        
        let dateString: String? = {
            if let date = date {
                return dateFormatter.string(from: date)
            } else {
                return nil
            }
        }()
        let isOn = dateString != nil
        let toggleAction = UIAction { [unowned self] action in
            guard let toggle = action.sender as? UISwitch else { return }
            if toggle.isOn {
                task.interval?.startDate = Date()
            } else {
                task.interval?.startDate = nil
            }
            
            reloadDateHeader(with: task.interval?.startDate)
        }
        
        let newHeaderItem = DatePickerItem.header(image: UIImage(systemName: "calendar"), text: "Date", secondaryText: dateString, isOn: isOn, action: toggleAction)
        var newSectionSnapshot = sectionSnapshot
        newSectionSnapshot.insert([newHeaderItem], before: oldHeaderItem)
        newSectionSnapshot.delete([oldHeaderItem])
        
        newSectionSnapshot.append([datePickerItem], to: newHeaderItem)
        
        if isOn {
            newSectionSnapshot.expand([newHeaderItem])
        }
        
        dataSource.apply(newSectionSnapshot, to: .interval)
    }
    
}

extension TaskEditorController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}
