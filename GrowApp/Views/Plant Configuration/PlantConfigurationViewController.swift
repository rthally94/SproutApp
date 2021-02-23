//
//  PlantConfigurationViewController.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/24/21.
//

import UIKit

class PlantConfigurationViewController: UIViewController {
    var plant: Plant? = nil {
        didSet {
            guard dataSource != nil else { return }
            if let strongPlant = plant {
                dataSource.apply(createDataSource(from: strongPlant))
            } else {
                dataSource.apply(createDefaultDataSource())
            }
        }
    }

    // Data Source View Models
    enum Section: Hashable, CaseIterable, CustomStringConvertible {
        case image
        case plantInfo
        case care

        var description: String {
            switch self {
                case .image: return "Image"
                case .plantInfo: return "General Information"
                case .care: return "Care Reminders"
            }
        }

        var headerTitle: String? {
            switch self {
                case .care: return description
                default: return nil
            }
        }

        var headerMode: UICollectionLayoutListConfiguration.HeaderMode {
            headerTitle == nil ? .none : .supplementary
        }
    }

    struct Item: Hashable {
        static func == (lhs: PlantConfigurationViewController.Item, rhs: PlantConfigurationViewController.Item) -> Bool {
            lhs.rowType == rhs.rowType
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(rowType)
        }

        let rowType: RowType
        let onTap: (() -> Void)?
    }

    enum RowType: Hashable {
        case plantIcon(PlantIcon)
        case list(image: UIImage?, text: String?, secondaryText: String?)
        case listValue(image: UIImage?, text: String?, secondaryText: String?)
        case textField(image: UIImage?, value: String?, placeholder: String?)
    }

    var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    var collectionView: UICollectionView! = nil
    internal var selectedIndexPath: IndexPath?

    override func loadView() {
        super.loadView()

        configureHiearchy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = .systemGroupedBackground
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedIndex = selectedIndexPath {
            collectionView.deselectItem(at: selectedIndex, animated: false)
        }
    }
}

extension PlantConfigurationViewController {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout() { sectionIndex, layoutEnvironment in
            let sectionInfo = Section.allCases[sectionIndex]

            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            config.headerMode = sectionInfo.headerMode

            switch sectionInfo {
                case .image:
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)

                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                    let section = NSCollectionLayoutSection(group: group)
                    section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0 )
                    return section
                default:
                    return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            }
        }

        return layout
    }

    private func configureHiearchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.delegate = self
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }
}

extension PlantConfigurationViewController: PlantIconPickerDelegate {
    func didChangeIcon(to icon: PlantIcon) {
        if let strongPlant = plant {
            strongPlant.icon = icon
            plant = strongPlant
        }
    }
}

extension PlantConfigurationViewController: PlantTypePickerDelegate {
    func plantTypePicker(didSelectType type: PlantType) {
        if let strongPlant = plant, strongPlant.type != type {
            strongPlant.type = type
            plant = strongPlant
//            dataSource.apply(createDataSource(from: strongPlant))
        }
    }
}

