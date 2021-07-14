//
//  UIImage+Thumbnail.swift
//  Sprout
//
//  Created by Ryan Thally on 6/15/21.
//

import UIKit

extension UIImage {
    func makeThumbnail() -> UIImage? {
        guard let imageData = self.orientedUp()?.pngData() else { return nil }
        let targetSize = 300

        let multipler = min(CGFloat(targetSize) / min(self.size.width, self.size.height), 1.0)
        let maxSideSize = max(self.size.width, self.size.height) * multipler

        let options = [
            kCGImageSourceShouldAllowFloat: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxSideSize
        ] as CFDictionary

        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
        guard let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else { return nil }
        return UIImage(cgImage: imageReference)
    }

    func orientedUp() -> UIImage? {
        if self.imageOrientation == UIImage.Orientation.up {
            return self /// already upright, no need for changes
        }
        UIGraphicsBeginImageContext(self.size)
        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return copy
    }
}
