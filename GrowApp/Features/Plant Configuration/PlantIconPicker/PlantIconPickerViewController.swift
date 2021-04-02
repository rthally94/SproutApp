//
//  PlantIconPickerViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/22/21.
//

import UIKit

protocol PlantIconPickerDelegate {
    func selectedIconDidChange(to icon: GHIcon?)
}

class PlantIconPickerViewController: UIViewController {
    internal var icon: GHIcon? {
        get {
            currentIcon
        }
        set {
            if newValue != currentIcon {
                currentIcon = newValue
                dataSource.apply(createSnapshot())
            }
        }
    }
    
    private var currentIcon: GHIcon?
    var delegate: PlantIconPickerDelegate?

    init(plant: GHPlant) {
        currentIcon = plant.icon
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    enum Section: Hashable, CaseIterable {
        case currentImage
        case recommended
        case icons
    }

    struct Item: Hashable {
        var icon: GHIcon?
        var image: UIImage?
        var tintColor: UIColor?
        
        init(icon: GHIcon?) {
            self.icon = icon
            self.image = nil
            self.tintColor = nil
        }
        
        init(image: UIImage?, tintColor: UIColor?) {
            self.icon = nil
            self.image = image
            self.tintColor = tintColor
        }
    }

    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil

    override func loadView() {
        super.loadView()

        configureHiearchy()
        configureDataSource()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissPicker))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveAndDismiss))

        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.title = "Plant Image"
    }

    @objc private func dismissPicker() {
        dismiss(animated: true)
    }

    @objc private func saveAndDismiss() {
        delegate?.selectedIconDidChange(to: icon)
        dismiss(animated: true)
    }
}

extension PlantIconPickerViewController {
    func makeLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout() { sectionIndex, layoutEnvironment in
            let sectionLayoutKind = Section.allCases[sectionIndex]

            switch sectionLayoutKind {
                case .currentImage:
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)

                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                    let section = NSCollectionLayoutSection(group: group)
                    section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0 )
                    return section
                default:
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/4), heightDimension: .fractionalWidth(1/4))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    let inset = layoutEnvironment.container.effectiveContentSize.width / 16
                    item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)

                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                    let section = NSCollectionLayoutSection(group: group)
                    return section
            }
        }
    }

    func configureHiearchy() {
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: makeLayout())
        collectionView.dataSource = dataSource
        collectionView.delegate = self

        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.pinToBoundsOf(view)
    }
}
