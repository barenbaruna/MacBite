//
//  AppAnimation.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

import SwiftUI

enum AppAnimation {
    static let smooth = Animation.spring(response: 0.38, dampingFraction: 0.82)
    static let reducedMotion = Animation.easeOut(duration: 0.15)
}
