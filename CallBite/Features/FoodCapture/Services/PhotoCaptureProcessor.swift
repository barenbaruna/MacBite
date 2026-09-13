//
//  PhotoCaptureProcessor.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

@preconcurrency import AVFoundation
import UIKit

nonisolated final class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate, @unchecked Sendable {
    private let completion: @Sendable (Result<UIImage, Error>) -> Void
    private var photoData: Data?
    private var processingError: Error?

    init(completion: @escaping @Sendable (Result<UIImage, Error>) -> Void) {
        self.completion = completion
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error {
            processingError = error
            return
        }

        photoData = photo.fileDataRepresentation()
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
        error: Error?
    ) {
        if let error {
            completion(.failure(error))
            return
        }

        if let processingError {
            completion(.failure(processingError))
            return
        }

        guard let photoData,
              let image = UIImage(data: photoData) else {
            completion(.failure(CameraServiceError.invalidPhotoData))
            return
        }

        completion(.success(image))
    }
}
