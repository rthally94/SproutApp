//
//  TimelineViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/17/21.
//

import Combine
import CoreData
import UIKit

class TaskCalendarViewController: UIViewController {
    private let dateFormatter = Utility.dateFormatter

    var selectedDate: Date = Date() {
        didSet {
            self.navigationItem.title = dateFormatter.string(from: selectedDate)
            weekPicker.selectDate(selectedDate, animated: true)
        }
    }

    var persistentContainer: NSPersistentContainer = AppDelegate.persistentContainer

    private var taskCalendarProvider: TaskCalendarProvider?
    private var data: [TaskType: [Plant]] = [:]
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var cancellables = Set<AnyCancellable>()
    
    lazy var weekPicker: WeekPicker = {
        let weekPicker = WeekPicker(frame: .zero)
        weekPicker.backgroundColor = UIColor(named: "NavBarColor")
        weekPicker.layer.masksToBounds = false
        weekPicker.layer.shadowRadius = 1
        weekPicker.layer.shadowOpacity = 0.2
        weekPicker.layer.shadowOffset = CGSize(width: 0, height: 0)
        weekPicker.delegate = self
        return weekPicker
    }()

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.backgroundColor = .clear
        collectionView.dataSource = dataSource
        collectionView.allowsSelection = false
        return collectionView
    }()

    typealias Section = String
    typealias Item = NSManagedObjectID


    // MARK: - View Life Cycle
    override func loadView() {
        super.loadView()
        
        configureHiearchy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        taskCalendarProvider = TaskCalendarProvider(managedObjectContext: persistentContainer.viewContext)

        dataSource = makeDataSource()
        taskCalendarProvider?.$snapshot
            .sink(receiveValue: { [weak self] snapshot in
                if let snapshot = snapshot {
                    self?.dataSource.apply(snapshot)
                }
            })
            .store(in: &cancellables)
        
        configureNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        selectedDate = Date()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        weekPicker.selectDate(selectedDate, animated: false)
    }
    
    // MARK:- Actions
    @objc private func openCalendarPicker() {
        let vc = DatePickerCardViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .automatic
        vc.delegate = self
        vc.selectedDate = selectedDate
        self.present(vc, animated: true)
    }
}

extension TaskCalendarViewController {
    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection in
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped )
            config.headerMode = .supplementary
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        }

        return layout
    }

    private func configureHiearchy() {
        weekPicker.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(weekPicker)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            weekPicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            weekPicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            weekPicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            weekPicker.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1/7, constant: 36),

            collectionView.topAnchor.constraint(equalTo: weekPicker.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureNavBar() {
        let calendarButton = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: self, action: #selector(openCalendarPicker))
        navigationItem.rightBarButtonItem = calendarButton

        let navigationBar = navigationController?.navigationBar
        let navigationBarAppearence = UINavigationBarAppearance()
        navigationBarAppearence.shadowColor = .clear
        navigationBarAppearence.backgroundColor = UIColor(named: "NavBarColor")
        navigationBar?.scrollEdgeAppearance = navigationBarAppearence
        navigationBar?.standardAppearance = navigationBarAppearence

        navigationBar?.isTranslucent = false
    }

    func selectDate(_ date: Date) {
        if date != selectedDate {
            selectedDate = date
        }
    }
}

extension TaskCalendarViewController: WeekPickerDelegate {
    func weekPicker(_ weekPicker: WeekPicker, didSelect date: Date) {
        selectDate(date)
    }
}

extension TaskCalendarViewController: DatePickerDelegate {
    func didSelect(date: Date) {
        selectDate(date)
    }
}

extension TaskCalendarViewController {
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        let plantTaskCellRegistration = createPlantCellRegistration()
        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: plantTaskCellRegistration, for: indexPath, item: item)
        }

        // TODO: - Supplemetary View Provider (Headers)
        let taskHeader = createHeaderRegistration()
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            switch elementKind {
                case UICollectionView.elementKindSectionHeader:
                    return collectionView.dequeueConfiguredReusableSupplementary(using: taskHeader, for: indexPath)
                default:
                    return nil
            }
        }

        return dataSource
    }

    private func createPlantCellRegistration() -> UICollectionView.CellRegistration<TaskCalendarListCell, Item> {
        return UICollectionView.CellRegistration<TaskCalendarListCell, Item> {cell, indexPath, item in
//            guard let task = self?.taskCalendarProvider.object(at: indexPath) else { return }

//            if item.task.currentStatus() == .complete {
//                cell.accessories = [.checkmark()]
//            } else {
//                let actionHander: UIActionHandler = {[weak self] _ in
//                    guard let self = self else { return }
//                    let plant = item.plant
//                    let task = item.task
//
//                    plant.logCare(for: task)
//                    self.reloadView()
//                }
//                cell.accessories = [
//                    .todoAccessory(actionHandler: actionHander)
//                ]
//            }
//
//            cell.updateWith(task: item.task, plant: item.plant)
        }
    }

    private func createHeaderRegistration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { cell, _, indexPath in
            // TODO: - configure cell
            let sortedKeys = self.data.keys.sorted(by: { $0.description < $1.description })
            if indexPath.section < sortedKeys.endIndex {
                let task = sortedKeys[indexPath.section]
                var config = UIListContentConfiguration.largeGroupedHeader()
                config.textProperties.color = task.accentColor ?? .label
                config.imageProperties.tintColor = task.accentColor

                if case let .symbol(symbolName, _) = task.icon {
                    config.image = UIImage(systemName: symbolName)
                } else if case let .image(image) = task.icon {
                    config.image = image
                }

                config.text = task.description

                cell.contentConfiguration = config
            }
        }
    }
}
