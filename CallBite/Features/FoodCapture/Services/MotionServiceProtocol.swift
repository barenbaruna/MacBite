//
//  MotionServiceProtocol.swift
//  CallBite
//
//  Created by Codex on 12/09/26.
//

import Combine

protocol MotionServiceProtocol: AnyObject {
    var motionPublisher: AnyPublisher<CameraMotionSample, Never> { get }

    func startUpdates()
    func stopUpdates()
}
