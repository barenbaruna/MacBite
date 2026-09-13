//
//  CameraServiceProtocol.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

@preconcurrency import AVFoundation
import Combine
import UIKit

protocol CameraServiceProtocol: AnyObject {
    var captureSession: AVCaptureSession { get }
    var frameAnalysisPublisher: AnyPublisher<CameraFrameAnalysis, Never> { get }

    func authorizationStatus() -> AVAuthorizationStatus
    func requestAccess() async -> Bool
    func configure() async throws -> Bool
    func startSession() async
    func stopSession()
    func setTorchEnabled(_ isEnabled: Bool) async throws
    func capturePhoto() async throws -> UIImage
}
