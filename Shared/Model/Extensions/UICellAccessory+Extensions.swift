//
//  UICellAccessory+Extensions.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/24/21.
//

import UIKit

extension UICellAccessory {
    static func taskTodoAccessory(actionHandler: @escaping UIActionHandler) -> UICellAccessory {
        let placement = UICellAccessory.Placement.trailing(displayed: .whenNotEditing)
        
        let todoAction: UIAction = .init(title: "Task Name", handler: actionHandler)
        let todoButton = UIButton(type: .system, primaryAction: todoAction)
        
        let configuration = UICellAccessory.CustomViewConfiguration(customView: todoButton, placement: placement)

        todoButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        todoButton.layer.borderColor = configuration.tintColor?.cgColor
        todoButton.layer.borderWidth = 3
        
        let todoAccessory = UICellAccessory.customView(configuration: configuration)
        return todoAccessory
    }
    
    static func todoAccessory(actionHandler: @escaping UIActionHandler) -> UICellAccessory {
        let placement = UICellAccessory.Placement.trailing(displayed: .whenNotEditing)
        
        let todoAction: UIAction = .init(image: UIImage(systemName: "circle"), handler: actionHandler)
        let todoButton = UIButton(type: .system, primaryAction: todoAction)
        
        let configuration = UICellAccessory.CustomViewConfiguration(customView: todoButton, placement: placement)
        let todoAccessory = UICellAccessory.customView(configuration: configuration)
        return todoAccessory
    }
    
    static func toggleAccessory(isOn: Bool, action: UIAction?) -> UICellAccessory {
        let placement = UICellAccessory.Placement.trailing(displayed: .always)
        let toggle = UISwitch(frame: .zero, primaryAction: action)
        
        if toggle.isOn != isOn {
            toggle.isOn = isOn
        }
        
        let configuration = UICellAccessory.CustomViewConfiguration(customView: toggle, placement: placement)
        let toggleAccessory = UICellAccessory.customView(configuration: configuration)
        return toggleAccessory
    }
}