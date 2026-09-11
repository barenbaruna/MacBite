//
//  ImagePreprocessingService.swift
//  CallBite
//
//  Created by Fathimah Az Zahra Sanjani on 11/09/26.
//
//  SINGLE SOURCE OF TRUTH for all CoreML image preprocessing in this pipeline.
//  Ported from FoodNutritionPOC (validated via parity test, see
//  CoreMLConversionReport.md in that project) — do not duplicate this logic
//  elsewhere. Any preprocessing change must be re-validated against the Python
//  conversion tooling before being changed here.
//

import CoreGraphics
import CoreImage
import CoreVideo
import UIKit
import VideoToolbox

/// Prepares a `UIImage` as a `CVPixelBuffer` for CoreML `ImageType` inputs.
/// Thread-safe (no mutable state).
final class ImagePreprocessingService {

    // MARK: - Constants

    /// Input size for the nutrition regression model (NutritionADMD).
    static let nutritionInputSize = CGSize(width: 224, height: 224)

    /// Input size for the food/non-food gate model (FoodGate).
    static let gateInputSize = CGSize(width: 512, height: 512)

    private let ciContext = CIContext(options: [.useSoftwareRenderer: false])

    // MARK: - Public API

    /// Prepare a pixel buffer for the nutrition regression model.
    ///
    /// NOTE: /255 scaling and ImageNet mean/std normalization are NOT done here —
    /// they are embedded in the NutritionADMD.mlpackage wrapper. Do not normalize twice.
    func prepareForNutrition(_ uiImage: UIImage) throws -> CVPixelBuffer {
        let oriented = fixOrientation(uiImage)
        return try resizeToPixelBuffer(oriented, size: Self.nutritionInputSize)
    }

    /// Prepare a pixel buffer for the food gate model.
    ///
    /// NOTE: /255 and normalization are already embedded in FoodGate.mlpackage.
    func prepareForGate(_ uiImage: UIImage) throws -> CVPixelBuffer {
        let oriented = fixOrientation(uiImage)
        return try resizeToPixelBuffer(oriented, size: Self.gateInputSize)
    }

    // MARK: - Internal Helpers

    /// Fix EXIF orientation so the image is upright before processing.
    private func fixOrientation(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }

        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        defer { UIGraphicsEndImageContext() }
        image.draw(in: CGRect(origin: .zero, size: image.size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }

    /// Resize to target size using bilinear WHOLE-FRAME square resize (not a center crop).
    /// This matches how both models were trained — squeezing the entire frame to
    /// square, not cropping it.
    private func resizeToPixelBuffer(_ image: UIImage, size: CGSize) throws -> CVPixelBuffer {
        guard let cgImage = image.cgImage else {
            throw AppError.imageDecodeFailed
        }

        let ciImage = CIImage(cgImage: cgImage)

        let scaleX = size.width / CGFloat(cgImage.width)
        let scaleY = size.height / CGFloat(cgImage.height)
        let scaled = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        var pixelBuffer: CVPixelBuffer?
        let attrs: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
        ]

        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(size.width), Int(size.height),
            kCVPixelFormatType_32BGRA,
            attrs as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            throw AppError.inferenceFailed("CVPixelBufferCreate failed with code \(status).")
        }

        ciContext.render(scaled, to: buffer)
        return buffer
    }
}
