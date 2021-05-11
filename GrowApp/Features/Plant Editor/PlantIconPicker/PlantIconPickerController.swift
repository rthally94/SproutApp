//
//  PlantIconPickerViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/22/21.
//

import CoreData
import UIKit

enum PlantIconPickerSection: Hashable, CaseIterable {
    case currentImage
    case recommended
    case icons
}

class PlantIconPickerController: StaticCollectionViewController<PlantIconPickerSection> {
    // MARK: - Properties

    var icon: SproutIcon? {
        didSet {
            if icon != oldValue {
                dataSource?.apply(makeSnapshot())
            }
        }
    }

    var delegate: PlantIconPickerControllerDelegate?
    var persistentContainer: NSPersistentContainer = AppDelegate.persistentContainer
    
    internal let imagePicker = UIImagePickerController()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.title = "Plant Image"

        // Start Change Tracking
        persistentContainer.viewContext.undoManager?.beginUndoGrouping()
        dataSource?.apply(makeSnapshot())
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonPressed() {
        delegate?.plantIconPickerDidCancel(self)
        persistentContainer.viewContext.undoManager?.endUndoGrouping()
        persistentContainer.viewContext.undoManager?.undoNestedGroup()

        dismiss(animated: true)
    }
    
    @objc private func doneButtonPressed() {
        if let icon = icon {
            delegate?.plantIconPicker(self, didSelectIcon: icon)
        }
        
        persistentContainer.viewContext.undoManager?.endUndoGrouping()
        dismiss(animated: true)
    }
    
    func updateUI(animated: Bool = true) {
        let snapshot = makeSnapshot()
        dataSource?
            .apply(snapshot, animatingDifferences: animated)
    }

    override func makeLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout() { sectionIndex, layoutEnvironment in
            let sectionLayoutKind = PlantIconPickerSection.allCases[sectionIndex]

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
}

private extension PlantIconPickerController {
    func makeSnapshot() -> NSDiffableDataSourceSnapshot<PlantIconPickerSection, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<PlantIconPickerSection, Item>()
        snapshot.appendSections(PlantIconPickerSection.allCases)

        let iconItem = Item.icon(image: icon?.image)
        snapshot.appendItems([iconItem], toSection: .currentImage)

        let cameraButtonItem = Item.button(image: UIImage(systemName: "camera"), onTap: {
            self.showImagePicker(preferredType: .camera)
        })
        let photoLibraryButton = Item.button(image: UIImage(systemName: "photo.on.rectangle"), onTap: {
            self.showImagePicker(preferredType: .photoLibrary)
        })
        snapshot.appendItems([cameraButtonItem, photoLibraryButton], toSection: .icons)

        return snapshot
    }
}
