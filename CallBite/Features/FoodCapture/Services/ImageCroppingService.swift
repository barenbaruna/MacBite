//
//  ImageCroppingService.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 12/09/26.
//

import UIKit

public protocol ImageCroppingServiceProtocol: Sendable {
    func cropImageToGuideScope(
        image: UIImage,
        guideFrame: CGRect,
        viewportSize: CGSize
    ) -> UIImage

    func cropToCenterSquare(image: UIImage) -> UIImage
}

public struct ImageCroppingService: ImageCroppingServiceProtocol {
    public init() {}

    public func cropImageToGuideScope(
        image: UIImage,
        guideFrame: CGRect,
        viewportSize: CGSize
    ) -> UIImage {
        guard viewportSize.width > 0,
              viewportSize.height > 0,
              guideFrame.width > 0,
              guideFrame.height > 0 else {
            return cropToCenterSquare(image: image)
        }

        let scale = max(viewportSize.width / image.size.width, viewportSize.height / image.size.height)
        guard scale > 0 else {
            return cropToCenterSquare(image: image)
        }

        let renderedWidth = image.size.width * scale
        let renderedHeight = image.size.height * scale
        let originX = (viewportSize.width - renderedWidth) / 2.0
        let originY = (viewportSize.height - renderedHeight) / 2.0

        let cropX = (guideFrame.minX - originX) / scale
        let cropY = (guideFrame.minY - originY) / scale
        let cropWidth = guideFrame.width / scale
        let cropHeight = guideFrame.height / scale

        let clampedX = max(0, min(cropX, image.size.width))
        let clampedY = max(0, min(cropY, image.size.height))
        let clampedWidth = max(0, min(cropWidth, image.size.width - clampedX))
        let clampedHeight = max(0, min(cropHeight, image.size.height - clampedY))

        guard clampedWidth > 10, clampedHeight > 10 else {
            return cropToCenterSquare(image: image)
        }

        let cropRect = CGRect(x: clampedX, y: clampedY, width: clampedWidth, height: clampedHeight)
        return renderCroppedImage(image, in: cropRect)
    }

    public func cropToCenterSquare(image: UIImage) -> UIImage {
        let side = min(image.size.width, image.size.height)
        guard side > 0 else { return image }
        let rect = CGRect(
            x: (image.size.width - side) / 2.0,
            y: (image.size.height - side) / 2.0,
            width: side,
            height: side
        )
        return renderCroppedImage(image, in: rect)
    }

    private func renderCroppedImage(_ image: UIImage, in rect: CGRect) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        let renderer = UIGraphicsImageRenderer(size: rect.size, format: format)
        return renderer.image { _ in
            image.draw(at: CGPoint(x: -rect.origin.x, y: -rect.origin.y))
        }
    }
}
