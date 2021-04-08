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
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return formatter
    }()

    var selectedDate: Date = Date() {
        didSet {
            self.navigationItem.title = TaskCalendarViewController.dateFormatter.string(from: selectedDate)
            weekPicker.selectDate(selectedDate, animated: true)
        }
    }
    
    let taskCalendarProvider: TaskCalendarProvider
    var data: [TaskType: [Plant]] = [:]
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    var cancellables = Set<AnyCancellable>()
    
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

    init(viewContext: NSManagedObjectContext) {
        self.taskCalendarProvider = TaskCalendarProvider(managedObjectContext: viewContext)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- View Controller Lifecycle
    override func loadView() {
        super.loadView()
        
        configureHiearchy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = makeDataSource()
        taskCalendarProvider.$snapshot
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
