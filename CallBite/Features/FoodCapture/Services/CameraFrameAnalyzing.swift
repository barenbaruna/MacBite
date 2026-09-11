//
//  CameraFrameAnalyzing.swift
//  CallBite
//
//  Created by Codex on 12/09/26.
//

@preconcurrency import AVFoundation

protocol CameraFrameAnalyzing: Sendable {
    func analyze(pixelBuffer: CVPixelBuffer) -> CameraFrameAnalysis
}
