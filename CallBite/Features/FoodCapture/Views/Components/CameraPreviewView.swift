//
//  CameraPreviewView.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

@preconcurrency import AVFoundation
import UIKit

final class CameraPreviewView: UIView {
    override static var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        guard let previewLayer = layer as? AVCaptureVideoPreviewLayer else {
            preconditionFailure("CameraPreviewView must use AVCaptureVideoPreviewLayer")
        }
        return previewLayer
    }
}
