//
//  MotionService.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 12/09/26.
//

import Combine
@preconcurrency import CoreMotion
import Foundation

final class MotionService: MotionServiceProtocol, @unchecked Sendable {
    var motionPublisher: AnyPublisher<CameraMotionSample, Never> {
        motionSubject.eraseToAnyPublisher()
    }

    private let motionManager = CMMotionManager()
    private let motionQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.callbite.camera.motion"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInteractive
        return queue
    }()
    private let motionSubject = PassthroughSubject<CameraMotionSample, Never>()

    func startUpdates() {
        guard motionManager.isDeviceMotionAvailable,
              !motionManager.isDeviceMotionActive else { return }

        motionManager.deviceMotionUpdateInterval = 1 / 30
        motionManager.startDeviceMotionUpdates(
            using: .xArbitraryZVertical,
            to: motionQueue
        ) { [weak self] motion, _ in
            guard let self, let motion else { return }

            let gravity = motion.gravity
            let cameraAxisAlignment = min(1, abs(gravity.z))
            let angleFromTable = asin(cameraAxisAlignment) * 180 / .pi
            let rotationRate = motion.rotationRate
            let rotationMagnitude = sqrt(
                rotationRate.x * rotationRate.x
                    + rotationRate.y * rotationRate.y
                    + rotationRate.z * rotationRate.z
            )

            motionSubject.send(
                CameraMotionSample(
                    angleFromTable: angleFromTable,
                    rotationRate: rotationMagnitude,
                    timestamp: motion.timestamp
                )
            )
        }
    }

    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }

    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}
