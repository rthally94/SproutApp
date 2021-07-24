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
        thumbnailImageData = correcetedImage?.makeThumbnail()?.jpegData(compressionQuality: 0.6)

        if fullImageData == nil {
            fullImageData = SproutImageDataMO(context: managedObjectContext!)
        }
        
        fullImageData?.rawData = correcetedImage?.jpegData(compressionQuality: 0.8)
    }

    public enum ImageSize {
        case auto, thumbnail, full
    }

    public func getImage(preferredSize: ImageSize = .auto) -> UIImage? {
        switch preferredSize {
        case .auto:
            // Try to get full size image, if fault, get the thumbnail
            // If thumbnail is not set, load the full image
            if fullImageData?.isFault == false, let imageData = fullImageData?.rawData, let image = UIImage(data: imageData) {
                return image
            }
            fallthrough

        case .thumbnail:
            // Try to load the thumbnail image
            // If unable, load the full image
            if let imageData = thumbnailImageData, let thumbnailImage = UIImage(data: imageData) {
                return thumbnailImage
            }
            fallthrough
        default:
            // Load the full image and cache thumbnail if not set
            if let imageData = fullImageData?.rawData, let fullImage = UIImage(data: imageData) {
                if thumbnailImageData == nil {
                    thumbnailImageData = fullImage.makeThumbnail()?.jpegData(compressionQuality: 0.8)
                }
                return fullImage
            }
            return nil
        }
    }
}
