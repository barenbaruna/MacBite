//
//  MockCameraGuideStore.swift
//  CallBiteTests
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

@testable import CallBite

final class MockCameraGuideStore: CameraGuideStoreProtocol {
    var hasSeenCameraGuide: Bool

    init(hasSeenCameraGuide: Bool) {
        self.hasSeenCameraGuide = hasSeenCameraGuide
    }

    func markCameraGuideAsSeen() {
        hasSeenCameraGuide = true
    }
}
