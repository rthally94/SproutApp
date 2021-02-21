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
        let rowType: RowType
        let destination: UIViewController?
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

    override func viewDidLoad() {
        super.viewDidLoad()

        configureHiearchy()
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

            let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            return section
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


