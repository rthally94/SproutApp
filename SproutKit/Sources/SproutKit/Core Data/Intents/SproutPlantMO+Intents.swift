//
//  File.swift
//  
//
//  Created by Ryan Thally on 6/26/21.
//

import UIKit

extension SproutPlantMO {
    func setImage(_ newImage: UIImage) {
        let correcetedImage = newImage.orientedUp()
        thumbnailImageData = correcetedImage?.makeThumbnail()?.pngData()
        fullImageData?.rawData = correcetedImage?.pngData()
    }

    enum ImageSize {
        case thumbnail, full
    }

    func getImage(preferredSize: ImageSize = .thumbnail) -> UIImage? {
        switch preferredSize {
        case .thumbnail:
            if let imageData = thumbnailImageData, let thumbnailImage = UIImage(data: imageData) {
                return thumbnailImage
            }
            fallthrough

        default:
            if let imageData = fullImageData?.rawData, let fullImage = UIImage(data: imageData) {
                return fullImage
            }
            return nil
        }
    }
}
