//
//  RegisterableCell.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/26/21.
//

import Foundation
import UIKit

protocol RegisterableCell: UICollectionViewCell {
    associatedtype Item: Hashable

    static func cellRegistration() -> UICollectionView.CellRegistration<Self, Item>
}
