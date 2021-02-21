//
//  PlantTypePicker.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/24/21.
//

import UIKit

class PlantTypePicker: UIView {
    var collectionView: UICollectionView!
    var choices: Set<String> = [
        "Foliage",
        "Flowering",
        "Succulent"
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureCollectionView()
        configureHiearchy()
        
        self.backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeLayout() -> UICollectionViewLayout {
        switch choices.count {
        case 1...3:
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0)), subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 16
            
            let layout = UICollectionViewCompositionalLayout(section: section)
            return layout
            
        default:
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0)))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60)), subitem: item, count: 1)
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 16
            
            let layout = UICollectionViewCompositionalLayout(section: section)
            return layout
        }
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.dataSource = self
        collectionView.register(OutlineImageCell.self, forCellWithReuseIdentifier: OutlineImageCell.reuseIdentifier)
        collectionView.backgroundColor = .clear
    }
    
    private func configureHiearchy() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.centerXAnchor.constraint(equalTo: centerXAnchor),
            collectionView.centerYAnchor.constraint(equalTo: centerYAnchor),
            collectionView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/3),
            collectionView.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }
}

extension PlantTypePicker: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OutlineImageCell.reuseIdentifier, for: indexPath) as? OutlineImageCell else { return UICollectionViewCell() }
        
        cell.imageView.image = UIImage(systemName: "drop.fill")
        cell.tintColor = .systemGray2
        
        return cell
    }
}
