//
//  File.swift
//  
//
//  Created by Ryan Thally on 6/26/21.
//

import UIKit

extension SproutPlantMO {
    public func setImage(_ newImage: UIImage?) {
        let correcetedImage = newImage?.orientedUp()
        thumbnailImageData = correcetedImage?.makeThumbnail()?.pngData()

        if fullImageData == nil {
            fullImageData = SproutImageDataMO(context: managedObjectContext!)
        }
        
        fullImageData?.rawData = correcetedImage?.pngData()
    }

    public enum ImageSize {
        case auto, thumbnail, full
    }

    public func getImage(preferredSize: ImageSize = .auto) -> UIImage? {
        switch preferredSize {
        case .auto:
            if fullImageData?.isFault == false, let imageData = fullImageData?.rawData, let image = UIImage(data: imageData) {
                return image
            }
            fallthrough

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
