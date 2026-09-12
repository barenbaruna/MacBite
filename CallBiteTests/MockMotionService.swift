//
//  MockMotionService.swift
//  CallBiteTests
//
//  Created by Codex on 12/09/26.
//

@testable import CallBite
import Combine

final class MockMotionService: MotionServiceProtocol {
    var motionPublisher: AnyPublisher<CameraMotionSample, Never> {
        motionSubject.eraseToAnyPublisher()
    }

    private(set) var isStarted = false
    private(set) var isStopped = false

    private let motionSubject = PassthroughSubject<CameraMotionSample, Never>()

    func startUpdates() {
        isStarted = true
    }

    func stopUpdates() {
        isStopped = true
    }

    func sendMotionSample(_ sample: CameraMotionSample) {
        motionSubject.send(sample)
    }
}
