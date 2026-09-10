//
//  UserDefaultsCameraGuideStore.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

import Foundation

final class UserDefaultsCameraGuideStore: CameraGuideStoreProtocol {
    private enum Key {
        static let hasSeenCameraGuide = "hasSeenCameraGuide"
    }

    private let userDefaults: UserDefaults

    var hasSeenCameraGuide: Bool {
        userDefaults.bool(forKey: Key.hasSeenCameraGuide)
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func markCameraGuideAsSeen() {
        userDefaults.set(true, forKey: Key.hasSeenCameraGuide)
    }
}
