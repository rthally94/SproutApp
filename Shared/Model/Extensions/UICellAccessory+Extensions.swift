//
//  UICellAccessory+Extensions.swift
//  GrowApp
//
//  Created by Ryan Thally on 3/24/21.
//

import UIKit

extension UICellAccessory {
    static func buttonAccessory(tintColor: UIColor?, action: UIAction) -> UICellAccessory {
        let placement = UICellAccessory.Placement.trailing(displayed: .whenNotEditing)
        let button = UIButton(primaryAction: action)
        button.tintColor = tintColor
        button.sizeToFit()

        let configuration = UICellAccessory.CustomViewConfiguration(customView: button, placement: placement)
        let buttonAccessory = UICellAccessory.customView(configuration: configuration)
        return buttonAccessory
    }
    
    static func dueTaskAccessory(actionHandler: @escaping UIActionHandler) -> UICellAccessory {
        let action = UIAction(image: UIImage(systemName: "circle"), handler: actionHandler)
        return .buttonAccessory(tintColor: .systemGray3, action: action)
    }

    static func doneTaskAccessory() -> UICellAccessory {
        let action = UIAction(image: UIImage(systemName: "checkmark.circle.fill")) { _ in }
        return buttonAccessory(tintColor: .systemGreen, action: action)
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
