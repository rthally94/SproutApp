//
//  TimelineViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/17/21.
//

import UIKit

class TimelineViewController: UIViewController, UICollectionViewDataSource {
    var collectionView: UICollectionView!
    
    override func loadView() {
        configureCollectionView()
        configureHiearchy()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        
        collectionView.dataSource = self
        
        collectionView.register(TimelineCell.self, forCellWithReuseIdentifier: TimelineCell.reuseIdentifier)
        
        collectionView.backgroundColor = .systemBackground
    }
    
    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }
        
        return layout
    }
    
    private func configureHiearchy() {
        view = collectionView
    }
    
    // MARK:- UICollectionView DataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimelineCell.reuseIdentifier, for: indexPath) as? TimelineCell else { fatalError("Unable to dequeu Timeline Cell") }
        
        cell.titleLabel.text = "Title"
        cell.subtitleLabel.text = "Subtitle"
        
        return cell
    }
}
