//
//  ImagePicking.swift
//  Sprout
//
//  Created by Ryan Thally on 7/6/21.
//

import UIKit

protocol ImagePicking: AnyObject {
    func showImagePicker(source: UIImagePickerController.SourceType)
}
