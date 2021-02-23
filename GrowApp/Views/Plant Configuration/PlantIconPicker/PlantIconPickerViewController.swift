//
//  PlantIconPickerViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/22/21.
//

import UIKit

protocol PlantIconPickerDelegate {
    func didChangeIcon(to icon: PlantIcon)
}

class PlantIconPickerViewController: UIViewController {

    var plant: Plant?
    var delegate: PlantIconPickerDelegate?

    func setPlantIcon(to icon: PlantIcon) {
        if icon != plant?.icon {
            plant?.icon = icon
            delegate?.didChangeIcon(to: icon)
            dataSource.apply(createDefaultSnapshot())
        }
    }

    enum Section: Hashable, CaseIterable {
        case currentImage
        case recommended
        case icons
    }

    struct Item: Hashable {
        static func == (lhs: PlantIconPickerViewController.Item, rhs: PlantIconPickerViewController.Item) -> Bool {
            lhs.icon == rhs.icon
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(icon)
        }

        var icon: PlantIcon
        var onTap: ( () -> Void )?
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
                    item.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

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

        collectionView.backgroundColor = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth , .flexibleHeight]
        view.addSubview(collectionView)
    }
}

extension PlantIconPickerViewController {
    func makeCellRegistration() -> UICollectionView.CellRegistration<PlantIconCell, Item> {
        return UICollectionView.CellRegistration<PlantIconCell, Item>() { cell, indexPath, item in
            cell.icon = item.icon
        }
    }

    func configureDataSource() {
        let cellRegistration = makeCellRegistration()

        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        dataSource.apply(createDefaultSnapshot())
    }

    func createDefaultSnapshot() -> NSDiffableDataSourceSnapshot<Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        snapshot.appendSections([.currentImage, .recommended])
        snapshot.appendItems([
            Item(icon: plant!.icon)
        ], toSection: .currentImage)

        snapshot.appendItems([
            Item(
                icon: .symbol(name: "camera", backgroundColor: .systemBlue),
                onTap: {
                    self.showImagePicker(preferredType: .camera)
                }
            ),
            Item(
                icon: .symbol(name: "photo.on.rectangle", backgroundColor: .systemBlue),
                onTap: {
                    self.showImagePicker(preferredType: .photoLibrary)
                }
            ),
            Item(icon: .symbol(name: "face.smiling", backgroundColor: .systemBlue)),
            Item(icon: .symbol(name: "pencil", backgroundColor: .systemBlue)),
        ], toSection: .recommended)

        return snapshot
    }
}

extension PlantIconPickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = dataSource.itemIdentifier(for: indexPath) {
            item.onTap?()
        }
    }
}

extension PlantIconPickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showImagePicker(preferredType: UIImagePickerController.SourceType = .photoLibrary) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.mediaTypes = ["public.image"]

        if UIImagePickerController.isSourceTypeAvailable(preferredType) {
            picker.sourceType = preferredType
        } else {
            picker.sourceType = .photoLibrary
        }

        if picker.sourceType == .camera {
            picker.cameraOverlayView = CameraOverlayView(frame: .zero)
        }

        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        setPlantIcon(to: PlantIcon.image(image))

        dismiss(animated: true)
    }
}
