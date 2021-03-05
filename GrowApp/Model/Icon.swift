//
//  PlantIcon.swift
//  GrowApp
//
//  Created by Ryan Thally on 2/17/21.
//

import UIKit

enum Icon: Hashable {
    case image(UIImage?)
    case symbol(name: String, foregroundColor: UIColor?, backgroundColor: UIColor?)
}
