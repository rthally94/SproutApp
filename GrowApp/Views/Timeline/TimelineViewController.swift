//
//  TimelineViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/17/21.
//

import UIKit

class TimelineViewController: UIViewController, UICollectionViewDataSource {
    static let sectionHeaderElementKind = "sectionHeaderElementKind"
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return formatter
    }()
    
    let model = GrowAppModel.preview
    
    var selectedDate: Date = Date()
    var plantsNeedingCare = [Plant]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var weekPicker = WeekPicker(frame: .zero)
    var collectionView: UICollectionView!
    
    override func loadView() {
        super.loadView()
        
        configureCollectionView()
        configureHiearchy()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.dataSource = self
        collectionView.register(TimelineCell.self, forCellWithReuseIdentifier: TimelineCell.reuseIdentifier)
        collectionView.backgroundColor = .clear
    }
    
    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            return section
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
            weekPicker.heightAnchor.constraint(equalTo: weekPicker.widthAnchor, multiplier: 1/7, constant: 36),

            collectionView.topAnchor.constraint(equalTo: weekPicker.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
    
    private func configureWeekPicker() {
        weekPicker.backgroundColor = UIColor(named: "NavBarColor")
        weekPicker.layer.masksToBounds = false
        weekPicker.layer.shadowRadius = 1
        weekPicker.layer.shadowOpacity = 0.2
        weekPicker.layer.shadowOffset = CGSize(width: 0, height: 0)
        weekPicker.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        configureWeekPicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        plantsNeedingCare = model.getPlantsNeedingCare(on: selectedDate)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        weekPicker.selectDate(selectedDate, animated: false)
    }
    
    // MARK:- Actions
    @objc private func openCalendarPicker() {
        let vc = DatePickerCardViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .automatic
        self.present(vc, animated: true)
    }
    
    // MARK:- UICollectionView DataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        plantsNeedingCare.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimelineCell.reuseIdentifier, for: indexPath) as? TimelineCell else { fatalError("Unable to dequeu Timeline Cell") }
        
        if indexPath.item == 0 {
            cell.imageView.image = UIImage(systemName: "drop.fill")
        }
        
        let plant = plantsNeedingCare[indexPath.item]
        
        cell.titleLabel.text = plant.id.uuidString
        cell.subtitleLabel.text = TimelineViewController.dateFormatter.string(from: Date())
        cell.cellBackground.backgroundColor = .systemGray6
        
        return cell
    }
}

extension TimelineViewController: WeekPickerDelegate {
    func weekPicker(_ weekPicker: WeekPicker, didSelect date: Date) {
        if date != selectedDate {
            selectedDate = date
            self.navigationItem.title = TimelineViewController.dateFormatter.string(from: selectedDate)
            self.plantsNeedingCare = model.getPlantsNeedingCare(on: selectedDate)
            self.collectionView.reloadData()
        }
    }
}
