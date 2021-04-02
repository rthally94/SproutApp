//
//  UICellAccessory+Extensions.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/24/21.
//

import UIKit

extension UICellAccessory {
    static func todoAccessory(actionHandler: @escaping UIActionHandler) -> UICellAccessory {
        let placement = UICellAccessory.Placement.trailing(displayed: .whenNotEditing)
        
        let todoAction: UIAction = .init(image: UIImage(systemName: "circle"), handler: actionHandler)
        let todoButton = UIButton(type: .system, primaryAction: todoAction)
        
        let configuration = UICellAccessory.CustomViewConfiguration(customView: todoButton, placement: placement)
        let todoAccessory = UICellAccessory.customView(configuration: configuration)
        return todoAccessory
    }
}
