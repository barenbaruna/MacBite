//
//  CameraFrameAnalyzing.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 12/09/26.
//

@preconcurrency import AVFoundation

protocol CameraFrameAnalyzing: Sendable {
    func analyze(pixelBuffer: CVPixelBuffer) -> CameraFrameAnalysis
}
