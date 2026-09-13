//
//  CameraGuideStoreProtocol.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

import Foundation

protocol CameraGuideStoreProtocol {
    var hasSeenCameraGuide: Bool { get }

    func markCameraGuideAsSeen()
}
