//
//  SproutIcon+Validation.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/29/21.
//

import UIKit

extension SproutIcon {
    func isHexColorValid() -> Bool {
        color != nil
    }

    func isImageValid() -> Bool {
        return imageData != nil
        && hexColor == nil
        && symbolName == nil
    }

    func isSymbolValid() -> Bool {
        return imageData == nil
        && hexColor != nil
        && symbolName != nil
    }
}
