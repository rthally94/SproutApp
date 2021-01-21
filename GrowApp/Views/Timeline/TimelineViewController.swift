//
//  TimelineViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/17/21.
//

import UIKit

class TimelineViewController: UIViewController, UICollectionViewDataSource {
    static let sectionHeaderElementKind = "sectionHeaderElementKind"
    
    let model = GrowAppModel.preview
    
    var plantsNeedingCare = [Plant]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return formatter
    }()
    
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
        collectionView.register(LargeHeader.self, forSupplementaryViewOfKind: TimelineViewController.sectionHeaderElementKind, withReuseIdentifier: LargeHeader.reuseIdentifer)
        
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
            
            let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize, elementKind: TimelineViewController.sectionHeaderElementKind, alignment: .topLeading)
            section.boundarySupplementaryItems = [sectionHeader]
            
            return section
        }
        
        return layout
    }
    
    private func configureHiearchy() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureNavBar() {
        navigationItem.title = TimelineViewController.dateFormatter.string(from: Date())
        
        let calendarButton = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: self, action: #selector(openCalendarPicker))
        navigationItem.rightBarButtonItem = calendarButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        plantsNeedingCare = model.getPlantsNeedingCare(on: Date())
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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == TimelineViewController.sectionHeaderElementKind, let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LargeHeader.reuseIdentifer, for: indexPath) as? LargeHeader else { return UICollectionReusableView() }
        
        header.textLabel.text = TimelineViewController.dateFormatter.string(from: Date())
        
        return header
    }
}
